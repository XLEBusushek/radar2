function plotQuadcopterTrajectories(quadcopters, config)
% plotQuadcopterTrajectories - Отображение траекторий квадрокоптеров с отличительным стилем.
arguments
    quadcopters struct
    config (1, 1) struct
end

if isempty(quadcopters)
    return;
end

hold on;

for i = 1:numel(quadcopters)
    qc = quadcopters(i);

    if ~isfield(qc, 'History') || ~isfield(qc.History, 'Position') || ...
            isempty(qc.History.Position)
        if isfield(qc, 'Position')
            pos = qc.Position(:);
            scatter3(pos(1), pos(2), pos(3), 36, [0.1, 0.4, 0.9], 'filled');
        end
        continue;
    end

    positions = qc.History.Position;
    plot3(positions(:, 1), positions(:, 2), positions(:, 3), ...
        '--', 'LineWidth', 1.4, 'Color', [0.1, 0.4, 0.9], ...
        'HandleVisibility', 'off');

    if isfield(config, 'visualization') && config.visualization.showStartEndPoints
        scatter3(positions(1, 1), positions(1, 2), positions(1, 3), ...
            36, [0.2, 0.8, 0.2], 'filled', 'HandleVisibility', 'off');
        scatter3(positions(end, 1), positions(end, 2), positions(end, 3), ...
            36, [0.9, 0.1, 0.1], 'filled', 'HandleVisibility', 'off');
    end

    if isfield(config, 'visualization') && config.visualization.showBirdIDs
        midIdx = ceil(size(positions, 1) / 2);
        text(positions(midIdx, 1), positions(midIdx, 2), positions(midIdx, 3), ...
            sprintf(' Q%d', qc.ID), 'FontSize', 8, 'Color', [0.1, 0.4, 0.9]);
    end
end

plot3(nan, nan, nan, '--', 'LineWidth', 1.4, 'Color', [0.1, 0.4, 0.9], ...
    'DisplayName', 'Quadcopter trajectories');
end
