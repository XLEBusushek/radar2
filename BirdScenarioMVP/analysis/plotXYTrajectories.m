function fig = plotXYTrajectories(scenario, config)
% plotXYTrajectories - Top-down XY view of trees, birds, and quadcopters.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
end

birds = getScenarioBirds(scenario);
quadcopters = getScenarioQuadcopters(scenario);
fixedWingUAVs = getScenarioFixedWingUAVs(scenario);
groundVehicles = getScenarioGroundVehicles(scenario);
fig = figure('Name', 'BirdScenario - Top View', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');
axis(ax, 'equal');

plotTargetXYHistory(ax, birds, '-', [0.85, 0.1, 0.1]);
plotTargetXYHistory(ax, quadcopters, '--', [0.1, 0.4, 0.9]);
plotTargetXYHistory(ax, fixedWingUAVs, '-.', [0.45, 0.15, 0.75]);
plotGroundRoutesXY(ax, groundVehicles, config);
plotTargetXYHistory(ax, groundVehicles, '-', [0.85, 0.45, 0.05]);

if isfield(scenario, 'RoadNetwork') && isfield(config, 'visualization') && ...
        isfield(config.visualization, 'showRoads') && config.visualization.showRoads
    plotRoadNetwork(scenario.RoadNetwork, ax);
end

function plotGroundRoutesXY(ax, groundVehicles, config)
maxRoutes = inf;
if isfield(config, 'visualization') && isfield(config.visualization, 'maxGroundRoutesToDraw')
    maxRoutes = config.visualization.maxGroundRoutesToDraw;
end
for i = 1:min(numel(groundVehicles), maxRoutes)
    target = groundVehicles(i);
    if ~isfield(target, 'Payload') || ~isfield(target.Payload, 'RoutePoints') || ...
            isempty(target.Payload.RoutePoints)
        continue;
    end
    pts = target.Payload.RoutePoints;
    plot(ax, pts(:, 1), pts(:, 2), ':', 'LineWidth', 1.2, ...
        'Color', [0.95, 0.65, 0.15], 'HandleVisibility', 'off');
end
end

if isfield(scenario, 'Trees') && ~isempty(scenario.Trees)
    trees = scenario.Trees;
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

    if isfield(config, 'fixedWing2') && config.fixedWing2.enabled
        zones = fw2_getZoneBounds(config);
        plotZoneRect(ax, zones.SafeZone, '--', [0.25, 0.65, 0.35], 'Safe Zone');
        plotZoneRect(ax, zones.WarningZone, ':', [0.85, 0.65, 0.15], 'Warning Zone');
    elseif isfield(config, 'fixedWing') && isfield(config.fixedWing, 'zones')
        zones = getFixedWingZoneBounds(config);
        plotZoneRect(ax, zones.CriticalZone, ':', [0.9, 0.35, 0.35], 'Critical Zone');
        plotZoneRect(ax, zones.WarningZone, '--', [0.85, 0.65, 0.15], 'Warning Zone');
        plotZoneRect(ax, zones.SafeZone, '-', [0.25, 0.65, 0.35], 'Safe Zone');
    elseif isfield(config, 'fixedWing') && isfield(config.fixedWing, 'boundary') && ...
            config.fixedWing.boundary.enabled
        margin = config.fixedWing.boundary.margin;
        bx = [margin, worldX - margin, worldX - margin, margin, margin];
        by = [margin, margin, worldY - margin, worldY - margin, margin];
        plot(ax, bx, by, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1, ...
            'DisplayName', 'Fixed-wing boundary margin');
    end
    xlim(ax, [0, worldX]);
    ylim(ax, [0, worldY]);
end

xlabel(ax, 'X (m)');
ylabel(ax, 'Y (m)');
title(ax, 'BirdScenario - Top View');
addStandardBirdLegend2D(ax);
hold(ax, 'off');
end

function plotZoneRect(ax, zone, lineStyle, color, label)
x = [zone(1), zone(2), zone(2), zone(1), zone(1)];
y = [zone(3), zone(3), zone(4), zone(4), zone(3)];
plot(ax, x, y, lineStyle, 'Color', color, 'LineWidth', 1.1, 'DisplayName', label);
end

function plotTargetXYHistory(ax, targets, lineStyle, color)
for i = 1:numel(targets)
    target = targets(i);
    if ~isfield(target, 'History') || ~isfield(target.History, 'Position') || ...
            isempty(target.History.Position)
        continue;
    end

    pos = target.History.Position;
    plot(ax, pos(:, 1), pos(:, 2), lineStyle, 'LineWidth', 1.2, ...
        'Color', color, 'HandleVisibility', 'off');

    plot(ax, pos(1, 1), pos(1, 2), 'o', 'MarkerSize', 6, ...
        'MarkerFaceColor', [0.2, 0.8, 0.2], 'MarkerEdgeColor', 'k', ...
        'HandleVisibility', 'off');
    plot(ax, pos(end, 1), pos(end, 2), 's', 'MarkerSize', 6, ...
        'MarkerFaceColor', [0.9, 0.1, 0.1], 'MarkerEdgeColor', 'k', ...
        'HandleVisibility', 'off');
end
end
