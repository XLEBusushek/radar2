function fig = plotAltitudeTime(scenario, config)
% plotAltitudeTime - Plot altitude versus time for birds and quadcopters.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
end

targets = [getScenarioBirds(scenario), getScenarioQuadcopters(scenario), ...
    getScenarioFixedWingUAVs(scenario)];
fig = figure('Name', 'BirdScenario - Altitude', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');

for i = 1:numel(targets)
    target = targets(i);
    if ~isfield(target, 'History') || ~isfield(target.History, 'Position') || ...
            isempty(target.History.Position)
        continue;
    end

    time = target.History.Time(:);
    altitude = target.History.Position(:, 3);
    if target.Class == "bird"
        style = '-';
        color = [0.85, 0.1, 0.1];
    elseif target.Class == "air" && target.Subtype == "fixedWingUAV"
        style = '-.';
        color = [0.45, 0.15, 0.75];
    else
        style = '--';
        color = [0.1, 0.4, 0.9];
    end
    plot(ax, time, altitude, style, 'LineWidth', 1.2, 'Color', color, ...
        'HandleVisibility', 'off');
end

xlabel(ax, 'Time (s)');
ylabel(ax, 'Altitude (m)');
title(ax, 'BirdScenario - Altitude');
hold(ax, 'off');
end
