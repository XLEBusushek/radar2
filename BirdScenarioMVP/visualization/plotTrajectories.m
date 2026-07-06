function fig = plotTrajectories(trajectoryLog, env, config)
% plotTrajectories - Top-down XY trajectories from TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    env (1, 1) struct
    config (1, 1) struct
end

fig = figure('Name', 'BirdScenario - Top View', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
axis(ax, 'equal');

plotLogTypeXY(ax, trajectoryLog, "bird", "", '-', [0.85, 0.1, 0.1]);
plotLogTypeXY(ax, trajectoryLog, "air", "quadcopter", '--', [0.1, 0.4, 0.9]);
plotLogTypeXY(ax, trajectoryLog, "air", "fixedWingUAV", '-.', [0.45, 0.15, 0.75]);
plotLogTypeXY(ax, trajectoryLog, "ground", "vehicle", '-', [0.85, 0.45, 0.05]);

if isfield(env, 'RoadNetwork') && isfield(config, 'visualization') && ...
        isfield(config.visualization, 'showRoads') && config.visualization.showRoads
    plotRoadNetwork(env.RoadNetwork, ax);
end

if isfield(config, 'visualization') && config.visualization.showTrees && ...
        isfield(env, 'Trees') && ~isempty(env.Trees)
    trees = env.Trees;
    treeX = arrayfun(@(t) t.Position(1), trees);
    treeY = arrayfun(@(t) t.Position(2), trees);
    plot(ax, treeX, treeY, '^', 'MarkerSize', 4, 'Color', [0.2, 0.5, 0.2], ...
        'MarkerFaceColor', [0.3, 0.6, 0.3], 'DisplayName', 'Trees');
end

if isfield(config, 'world') && isfield(config.world, 'size')
    worldX = config.world.size(1);
    worldY = config.world.size(2);
    bx = [0, worldX, worldX, 0, 0];
    by = [0, 0, worldY, worldY, 0];
    plot(ax, bx, by, '-', 'Color', [0.3, 0.3, 0.3], 'LineWidth', 1.2, ...
        'DisplayName', 'World');
    xlim(ax, [0, worldX]);
    ylim(ax, [0, worldY]);
end

if isfield(config, 'fixedWing2') && config.fixedWing2.enabled
    plotFW2Zones(ax, config);
end

xlabel(ax, 'X (m)');
ylabel(ax, 'Y (m)');
title(ax, 'Target trajectories (top view)');
addStandardBirdLegend2D(ax);
hold(ax, 'off');
end

function plotLogTypeXY(ax, log, className, subtype, style, color)
if ~isfield(log, 'Frames') || isempty(log.Frames)
    return;
end
ids = getUniqueTargetIds(log, className, subtype);
for id = ids(:).'
    history = buildTargetHistoryFromLog(log, id);
    if isempty(history.Time)
        continue;
    end
    plot(ax, history.Position(:, 1), history.Position(:, 2), style, ...
        'Color', color, 'LineWidth', 1.2);
end
end

function plotFW2Zones(ax, config)
zones = fw2_getZoneBounds(config);
safe = zones.SafeZone;
warn = zones.WarningZone;
rectangle(ax, 'Position', [safe(1), safe(3), safe(2) - safe(1), safe(4) - safe(3)], ...
    'EdgeColor', [0.2, 0.7, 0.2], 'LineStyle', '--');
rectangle(ax, 'Position', [warn(1), warn(3), warn(2) - warn(1), warn(4) - warn(3)], ...
    'EdgeColor', [0.9, 0.7, 0.1], 'LineStyle', ':');
end
