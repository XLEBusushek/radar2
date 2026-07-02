function plotGroundVehicleTrajectories(groundVehicles, config)
% plotGroundVehicleTrajectories - Plot ground vehicle trajectories.
arguments
    groundVehicles struct
    config (1, 1) struct
end

if isempty(groundVehicles)
    return;
end

hold on;
color = [0.85, 0.45, 0.05];
maxRoutes = inf;
if isfield(config, 'visualization') && isfield(config.visualization, 'maxGroundRoutesToDraw')
    maxRoutes = config.visualization.maxGroundRoutesToDraw;
end
for i = 1:numel(groundVehicles)
    vehicle = groundVehicles(i);
    if i <= maxRoutes && isfield(vehicle, 'Payload') && isfield(vehicle.Payload, 'RoutePoints') && ...
            ~isempty(vehicle.Payload.RoutePoints)
        routePoints = vehicle.Payload.RoutePoints;
        plot3(routePoints(:, 1), routePoints(:, 2), routePoints(:, 3) + 0.2, ...
            ':', 'LineWidth', 1.3, 'Color', [0.95, 0.65, 0.15], ...
            'HandleVisibility', 'off');
        scatter3(routePoints(1, 1), routePoints(1, 2), routePoints(1, 3), ...
            32, [0.2, 0.8, 0.2], 'filled', 'HandleVisibility', 'off');
        scatter3(routePoints(end, 1), routePoints(end, 2), routePoints(end, 3), ...
            32, [0.9, 0.1, 0.1], 'filled', 'HandleVisibility', 'off');
    end
    if ~isfield(vehicle, 'History') || ~isfield(vehicle.History, 'Position') || ...
            isempty(vehicle.History.Position)
        pos = vehicle.Position(:);
        scatter3(pos(1), pos(2), pos(3), 36, color, 'filled');
        continue;
    end

    positions = vehicle.History.Position;
    plot3(positions(:, 1), positions(:, 2), positions(:, 3), ...
        '-', 'LineWidth', 1.5, 'Color', color, 'HandleVisibility', 'off');

    if isfield(config, 'visualization') && config.visualization.showStartEndPoints
        scatter3(positions(1, 1), positions(1, 2), positions(1, 3), ...
            32, [0.2, 0.8, 0.2], 'filled', 'HandleVisibility', 'off');
        scatter3(positions(end, 1), positions(end, 2), positions(end, 3), ...
            32, [0.9, 0.1, 0.1], 'filled', 'HandleVisibility', 'off');
    end

    if isfield(config, 'visualization') && config.visualization.showBirdIDs
        midIdx = ceil(size(positions, 1) / 2);
        text(positions(midIdx, 1), positions(midIdx, 2), positions(midIdx, 3), ...
            sprintf(' G%d', vehicle.ID), 'FontSize', 8, 'Color', color);
    end

    currentPos = positions(end, :);
    scatter3(currentPos(1), currentPos(2), currentPos(3), 50, color, ...
        'filled', 'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
    if isfield(vehicle, 'Velocity') && norm(vehicle.Velocity(1:2)) > 1e-6
        dir = vehicle.Velocity(:).' / max(norm(vehicle.Velocity(1:2)), 1e-6);
        quiver3(currentPos(1), currentPos(2), currentPos(3), ...
            20 * dir(1), 20 * dir(2), 0, 0, 'Color', color, ...
            'LineWidth', 1.2, 'MaxHeadSize', 1.5, 'HandleVisibility', 'off');
    end
end

plot3(nan, nan, nan, '-', 'LineWidth', 1.5, 'Color', color, ...
    'DisplayName', 'Ground vehicle trajectories');
plot3(nan, nan, nan, ':', 'LineWidth', 1.3, 'Color', [0.95, 0.65, 0.15], ...
    'DisplayName', 'Ground routes');
end
