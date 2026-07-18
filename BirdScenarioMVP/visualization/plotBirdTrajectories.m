function plotBirdTrajectories(birds, config)
% plotBirdTrajectories - Отображение траекторий птиц с опциональным оформлением по состояниям.
arguments
    birds struct
    config (1, 1) struct
end

if isempty(birds)
    return;
end

hold on;

useStateSegments = shouldPlotStateSegments(config);
useInvisibleSegments = shouldPlotInvisibleSegments(config);

for i = 1:numel(birds)
    bird = birds(i);

    if ~isfield(bird, 'History') || ~isfield(bird.History, 'Position') || ...
            isempty(bird.History.Position)
        if isfield(bird, 'Position')
            pos = bird.Position(:);
            scatter3(pos(1), pos(2), pos(3), 36, 'r', 'filled');
        end
        continue;
    end

    if useStateSegments
        plotBirdStateSegments(bird, config);
        if useInvisibleSegments
            plotVisibilitySegments(bird, config, true);
        end
        continue;
    end

    positions = bird.History.Position;
    plot3(positions(:, 1), positions(:, 2), positions(:, 3), ...
        '-', 'LineWidth', 1.2, 'Color', [0.85, 0.1, 0.1], ...
        'HandleVisibility', 'off');

    if useInvisibleSegments
        plotVisibilitySegments(bird, config);
    end

    if isfield(config, 'visualization') && config.visualization.showStartEndPoints
        scatter3(positions(1, 1), positions(1, 2), positions(1, 3), ...
            36, 'g', 'filled', 'HandleVisibility', 'off');
        scatter3(positions(end, 1), positions(end, 2), positions(end, 3), ...
            36, 'r', 'filled', 'HandleVisibility', 'off');
        plot3(nan, nan, nan, 'o', 'MarkerSize', 6, ...
            'MarkerFaceColor', [0.2, 0.8, 0.2], 'MarkerEdgeColor', 'k', ...
            'DisplayName', 'Start');
        plot3(nan, nan, nan, 's', 'MarkerSize', 6, ...
            'MarkerFaceColor', [0.9, 0.1, 0.1], 'MarkerEdgeColor', 'k', ...
            'DisplayName', 'End');
    end

    if isfield(config, 'visualization') && config.visualization.showBirdIDs
        midIdx = ceil(size(positions, 1) / 2);
        text(positions(midIdx, 1), positions(midIdx, 2), positions(midIdx, 3), ...
            sprintf(' %d', bird.ID), 'FontSize', 8);
    end
end

if ~useStateSegments
    plot3(nan, nan, nan, '-', 'LineWidth', 1.2, 'Color', [0.85, 0.1, 0.1], ...
        'DisplayName', 'Trajectory');
end
end
