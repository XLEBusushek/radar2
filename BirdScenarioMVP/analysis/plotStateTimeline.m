function fig = plotStateTimeline(scenario, config)
% plotStateTimeline - Plot FSM state timeline for birds and quadcopters.
arguments
    scenario (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
end

if isfield(scenario, 'Targets') && ~isempty(scenario.Targets)
    targets = scenario.Targets;
else
    targets = [getScenarioBirds(scenario), getScenarioQuadcopters(scenario)];
end

maxTargets = min(numel(targets), 12);
fig = figure('Name', 'BirdScenario - FSM States', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');

for i = 1:maxTargets
    target = targets(i);
    if ~isfield(target, 'History') || ~isfield(target.History, 'State') || ...
            isempty(target.History.State)
        continue;
    end

    time = target.History.Time(:);
    states = string(target.History.State(:));
    stateValues = arrayfun(@stateToNumeric, states);
    label = sprintf('%s %d', target.Class, target.ID);
    plot(ax, time, stateValues, '-', 'LineWidth', 1.5, 'DisplayName', label);
end

yticks(ax, [1:5, 10:14, 20:24, 30:35]);
yticklabels(ax, {'1 Perched', '2 Takeoff', '3 Cruise', '4 Landing', '5 Hidden', ...
    '10 Idle', '11 Transit', '12 Hover', '13 Scan', '14 Return', ...
    '20 Drive', '21 Stop', '22 Turn', '23 LeaveRoad', '24 ReturnRoad', ...
    '30 Climb', '31 Descend', '32 Loiter', '33 Dive', '34 Recover', '35 ExitArea'});
ylim(ax, [0.5, 35.5]);

xlabel(ax, 'Time (s)');
ylabel(ax, 'State');
title(ax, 'BirdScenario - FSM States');
if maxTargets <= 12
    legend(ax, 'Location', 'bestoutside');
end
hold(ax, 'off');
end
