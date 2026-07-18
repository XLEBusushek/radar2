function plotBirdStateSegments(bird, config)
% plotBirdStateSegments - Отображение сегментов траектории, окрашенных по состоянию FSM.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

if ~isfield(bird, 'History') || ~isfield(bird.History, 'Position') || ...
        isempty(bird.History.Position)
    return;
end

pos = bird.History.Position;
states = string(bird.History.State(:));
numPoints = size(pos, 1);

if numPoints == 0
    return;
end

if numPoints == 1
    style = getStatePlotStyle(states(1));
    plot3(pos(1, 1), pos(1, 2), pos(1, 3), ...
        'LineStyle', 'none', 'Marker', style.Marker, ...
        'Color', style.Color, 'MarkerSize', 5, ...
        'HandleVisibility', 'off');
    return;
end

segments = findStateSegments(states);

for s = 1:size(segments, 1)
    idxStart = segments(s, 1);
    idxEnd = segments(s, 2);
    state = states(idxStart);
    style = getStatePlotStyle(state);

    if state == "Hidden"
        continue;
    end

    segmentPos = pos(idxStart:idxEnd, :);

    if size(segmentPos, 1) == 1
        plot3(segmentPos(1, 1), segmentPos(1, 2), segmentPos(1, 3), ...
            'LineStyle', 'none', 'Marker', style.Marker, ...
            'Color', style.Color, 'MarkerSize', 5, ...
            'HandleVisibility', 'off');
    else
        plot3(segmentPos(:, 1), segmentPos(:, 2), segmentPos(:, 3), ...
            'LineStyle', style.LineStyle, 'LineWidth', style.LineWidth, ...
            'Color', style.Color, 'Marker', style.Marker, ...
            'HandleVisibility', 'off');
    end
end

if isfield(config, 'visualization') && config.visualization.showStartEndPoints
    plotBirdStartEndPoints(bird);
end

if isfield(config, 'visualization') && config.visualization.showBirdIDs
    plotBirdIDLabel(bird);
end
end

function segments = findStateSegments(states)
numPoints = numel(states);
segments = zeros(0, 2);
startIdx = 1;

for i = 2:numPoints
    if states(i) ~= states(i - 1)
        segments(end + 1, :) = [startIdx, i - 1]; %#ok<AGROW>
        startIdx = i;
    end
end
segments(end + 1, :) = [startIdx, numPoints];
end

function plotBirdStartEndPoints(bird)
pos = bird.History.Position;
plot3(pos(1, 1), pos(1, 2), pos(1, 3), 'o', ...
    'MarkerSize', 6, 'MarkerFaceColor', [0.2, 0.8, 0.2], ...
    'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
plot3(pos(end, 1), pos(end, 2), pos(end, 3), 's', ...
    'MarkerSize', 6, 'MarkerFaceColor', [0.9, 0.1, 0.1], ...
    'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
end

function plotBirdIDLabel(bird)
pos = bird.History.Position;
midIdx = ceil(size(pos, 1) / 2);
text(pos(midIdx, 1), pos(midIdx, 2), pos(midIdx, 3), ...
    sprintf(' %d', bird.ID), 'FontSize', 8, 'Color', [0.1, 0.1, 0.1]);
end
