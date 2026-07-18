function fig = plotVisibilityTimeline(scenario, config)
% plotVisibilityTimeline - График временной шкалы видимости для птиц и квадрокоптеров.
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
fig = figure('Name', 'BirdScenario - Visibility', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');

for i = 1:maxTargets
    target = targets(i);
    if ~isfield(target, 'History') || isempty(target.History.Time)
        continue;
    end

    time = target.History.Time(:);
    if isfield(target.History, 'Visible') && ~isempty(target.History.Visible)
        visibility = double(target.History.Visible(:));
    else
        visibility = ones(size(time));
    end

    plot(ax, time, visibility, '-', 'LineWidth', 1.5, ...
        'DisplayName', sprintf('%s %d', target.Class, target.ID));
end

yticks(ax, [0, 1]);
yticklabels(ax, {'0 Hidden', '1 Visible'});
ylim(ax, [-0.1, 1.1]);

xlabel(ax, 'Time (s)');
ylabel(ax, 'Visibility');
title(ax, 'BirdScenario - Visibility');
if maxTargets <= 12
    legend(ax, 'Location', 'bestoutside');
end
hold(ax, 'off');
end
