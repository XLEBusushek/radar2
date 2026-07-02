function plotFixedWingUAVTrajectories(fixedWingUAVs, config)
% plotFixedWingUAVTrajectories - Plot fixed-wing UAV trajectories.
arguments
    fixedWingUAVs struct
    config (1, 1) struct
end

if isempty(fixedWingUAVs)
    return;
end

hold on;
color = [0.45, 0.15, 0.75];
for i = 1:numel(fixedWingUAVs)
    uav = fixedWingUAVs(i);
    if ~isfield(uav, 'History') || ~isfield(uav.History, 'Position') || ...
            isempty(uav.History.Position)
        if isfield(uav, 'Position')
            pos = uav.Position(:);
            scatter3(pos(1), pos(2), pos(3), 40, color, 'filled');
        end
        continue;
    end

    positions = uav.History.Position;
    plot3(positions(:, 1), positions(:, 2), positions(:, 3), ...
        '-.', 'LineWidth', 1.5, 'Color', color, 'HandleVisibility', 'off');

    if isfield(config, 'visualization') && config.visualization.showStartEndPoints
        scatter3(positions(1, 1), positions(1, 2), positions(1, 3), ...
            36, [0.2, 0.8, 0.2], 'filled', 'HandleVisibility', 'off');
        scatter3(positions(end, 1), positions(end, 2), positions(end, 3), ...
            36, [0.9, 0.1, 0.1], 'filled', 'HandleVisibility', 'off');
    end

    if isfield(config, 'visualization') && config.visualization.showBirdIDs
        midIdx = ceil(size(positions, 1) / 2);
        text(positions(midIdx, 1), positions(midIdx, 2), positions(midIdx, 3), ...
            sprintf(' F%d', uav.ID), 'FontSize', 8, 'Color', color);
    end
end

plot3(nan, nan, nan, '-.', 'LineWidth', 1.5, 'Color', color, ...
    'DisplayName', 'Fixed-wing UAV trajectories');
end
