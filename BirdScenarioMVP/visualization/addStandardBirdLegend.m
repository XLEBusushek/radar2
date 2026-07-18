function addStandardBirdLegend(ax)
% addStandardBirdLegend - Добавление компактной легенды с уникальными записями траекторий.
arguments
    ax (1, 1) matlab.graphics.axis.Axes
end

hold(ax, 'on');
legendHandles = gobjects(0);
labels = strings(0, 1);
legendHandles(end + 1) = plot3(ax, nan, nan, nan, '-', 'Color', [0.85, 0.1, 0.1], 'LineWidth', 1.2, ...
    'DisplayName', 'Bird trajectories');
labels(end + 1) = "Bird trajectories";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, '--', 'Color', [0.1, 0.4, 0.9], 'LineWidth', 1.4, ...
    'DisplayName', 'Quadcopter trajectories');
labels(end + 1) = "Quadcopter trajectories";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, '-.', 'Color', [0.45, 0.15, 0.75], 'LineWidth', 1.5, ...
    'DisplayName', 'Fixed-wing UAV trajectories');
labels(end + 1) = "Fixed-wing UAV trajectories";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, '-', 'Color', [0.85, 0.45, 0.05], 'LineWidth', 1.5, ...
    'DisplayName', 'Ground vehicle trajectories');
labels(end + 1) = "Ground vehicle trajectories";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, ':', 'Color', [0.95, 0.65, 0.15], 'LineWidth', 1.3, ...
    'DisplayName', 'Ground routes');
labels(end + 1) = "Ground routes";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, '-', 'Color', [0.05, 0.05, 0.05], 'LineWidth', 3, ...
    'DisplayName', 'Main roads');
labels(end + 1) = "Main roads";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, '-', 'Color', [0.35, 0.35, 0.35], 'LineWidth', 1.8, ...
    'DisplayName', 'Secondary roads');
labels(end + 1) = "Secondary roads";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, '-', 'Color', [0.25, 0.25, 0.25], 'LineWidth', 2, ...
    'DisplayName', 'Road network');
labels(end + 1) = "Road network";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, 'o', 'MarkerSize', 6, ...
    'MarkerFaceColor', [0.2, 0.8, 0.2], 'MarkerEdgeColor', 'k', ...
    'DisplayName', 'Start');
labels(end + 1) = "Start";
legendHandles(end + 1) = plot3(ax, nan, nan, nan, 's', 'MarkerSize', 6, ...
    'MarkerFaceColor', [0.9, 0.1, 0.1], 'MarkerEdgeColor', 'k', ...
    'DisplayName', 'End');
labels(end + 1) = "End";

lineHandles = findobj(ax, 'Type', 'line');
for lineHandle = flipud(lineHandles(:).')
    label = get(lineHandle, 'DisplayName');
    if isempty(label) || ismember(label, {'Bird trajectories', 'Quadcopter trajectories', ...
            'Fixed-wing UAV trajectories', 'Ground vehicle trajectories', 'Ground routes', ...
            'Main roads', 'Secondary roads', 'Road network', 'Intersections', 'Start', 'End', 'Trees'})
        continue;
    end
    set(lineHandle, 'HandleVisibility', 'off');
end

legend(ax, legendHandles, labels, 'Location', 'bestoutside');
end
