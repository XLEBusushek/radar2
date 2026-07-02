function plotVisibilitySegments(bird, config, invisibleOnly)
% plotVisibilitySegments - Plot visible and invisible trajectory segments.
arguments
    bird (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
    invisibleOnly (1, 1) logical = false
end

if ~isfield(bird, 'History') || ~isfield(bird.History, 'Position') || ...
        isempty(bird.History.Position)
    return;
end

pos = bird.History.Position;
if ~isfield(bird.History, 'Visible')
    visible = true(size(pos, 1), 1);
else
    visible = logical(bird.History.Visible(:));
end

numPoints = size(pos, 1);
if numPoints == 0
    return;
end

segments = findVisibilitySegments(visible);
legendVisibleAdded = false;
legendInvisibleAdded = false;

for s = 1:size(segments, 1)
    idxStart = segments(s, 1);
    idxEnd = segments(s, 2);
    isVisible = visible(idxStart);
    segmentPos = pos(idxStart:idxEnd, :);

    if ~isVisible
        displayName = '';
        if ~legendInvisibleAdded
            displayName = 'Invisible';
            legendInvisibleAdded = true;
        end
        if size(segmentPos, 1) >= 2
            plot3(segmentPos(:, 1), segmentPos(:, 2), segmentPos(:, 3), ...
                ':', 'LineWidth', 0.8, 'Color', [0.55, 0.55, 0.55], ...
                'DisplayName', displayName);
        end
        continue;
    end

    if invisibleOnly
        continue;
    end

    displayName = '';
    if ~legendVisibleAdded
        displayName = 'Visible';
        legendVisibleAdded = true;
    end
    if size(segmentPos, 1) == 1
        plot3(segmentPos(1, 1), segmentPos(1, 2), segmentPos(1, 3), ...
            'o', 'MarkerSize', 4, 'Color', [0.85, 0.1, 0.1], ...
            'DisplayName', displayName);
    else
        plot3(segmentPos(:, 1), segmentPos(:, 2), segmentPos(:, 3), ...
            '-', 'LineWidth', 1.2, 'Color', [0.85, 0.1, 0.1], ...
            'DisplayName', displayName);
    end
end
end

function segments = findVisibilitySegments(visible)
numPoints = numel(visible);
segments = zeros(0, 2);
startIdx = 1;

for i = 2:numPoints
    if visible(i) ~= visible(i - 1)
        segments(end + 1, :) = [startIdx, i - 1]; %#ok<AGROW>
        startIdx = i;
    end
end
segments(end + 1, :) = [startIdx, numPoints];
end
