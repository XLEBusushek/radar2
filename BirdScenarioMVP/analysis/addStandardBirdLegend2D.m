function addStandardBirdLegend2D(ax)
% addStandardBirdLegend2D - Добавить компактные записи легенды XY.
arguments
    ax (1, 1) matlab.graphics.axis.Axes
end

hold(ax, 'on');
plot(ax, nan, nan, '-', 'Color', [0.85, 0.1, 0.1], 'LineWidth', 1.2, ...
    'DisplayName', 'Bird trajectories');
plot(ax, nan, nan, '--', 'Color', [0.1, 0.4, 0.9], 'LineWidth', 1.4, ...
    'DisplayName', 'Quadcopter trajectories');
plot(ax, nan, nan, 'o', 'MarkerSize', 6, ...
    'MarkerFaceColor', [0.2, 0.8, 0.2], 'MarkerEdgeColor', 'k', ...
    'DisplayName', 'Start');
plot(ax, nan, nan, 's', 'MarkerSize', 6, ...
    'MarkerFaceColor', [0.9, 0.1, 0.1], 'MarkerEdgeColor', 'k', ...
    'DisplayName', 'End');

lineHandles = findobj(ax, 'Type', 'line');
for h = flipud(lineHandles(:).')
    label = get(h, 'DisplayName');
    if isempty(label) || ismember(label, {'Bird trajectories', 'Quadcopter trajectories', ...
            'Start', 'End', 'Trees'})
        continue;
    end
    set(h, 'HandleVisibility', 'off');
end

legend(ax, 'Location', 'best');
end
