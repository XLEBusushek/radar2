function fig = plotSpeedTime(scenario, config)
% plotSpeedTime - График величины скорости от времени для птиц и квадрокоптеров.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
end

targets = [getScenarioBirds(scenario), getScenarioQuadcopters(scenario), ...
    getScenarioFixedWingUAVs(scenario)];
fig = figure('Name', 'BirdScenario - Speed', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');

allTimes = [];
for i = 1:numel(targets)
    target = targets(i);
    if ~isfield(target, 'History') || ~isfield(target.History, 'Velocity') || ...
            isempty(target.History.Velocity)
        continue;
    end

    time = target.History.Time(:);
    vel = target.History.Velocity;
    speed = vecnorm(vel, 2, 2);
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
    plot(ax, time, speed, style, 'LineWidth', 1.2, 'Color', color, ...
        'HandleVisibility', 'off');
    allTimes = [allTimes; time]; %#ok<AGROW>
end

maxSpeed = 20;
if isfield(config, 'birds') && isfield(config.birds, 'motion') && ...
        isfield(config.birds.motion, 'speedRange')
    maxSpeed = max(maxSpeed, config.birds.motion.speedRange(2));
end
if isfield(config, 'quadcopter') && isfield(config.quadcopter, 'speedRange')
    maxSpeed = max(maxSpeed, config.quadcopter.speedRange(2));
end
if isfield(config, 'fixedWing') && isfield(config.fixedWing, 'speedRange')
    maxSpeed = max(maxSpeed, config.fixedWing.speedRange(2));
end

if ~isempty(allTimes)
    tRange = [min(allTimes), max(allTimes)];
    plot(ax, tRange, [maxSpeed, maxSpeed], 'r--', 'LineWidth', 1, ...
        'DisplayName', sprintf('%.0f m/s max', maxSpeed));
end

xlabel(ax, 'Time (s)');
ylabel(ax, 'Speed (m/s)');
title(ax, 'BirdScenario - Speed');
legend(ax, 'Location', 'best');
hold(ax, 'off');
end
