function cache = buildTargetHistoryCache(trajectoryLog)
% buildTargetHistoryCache - Построить все истории целей за один проход по логу.
arguments
    trajectoryLog (1, 1) struct
end

cache = containers.Map('KeyType', 'double', 'ValueType', 'any');
numFrames = getLogFrameCount(trajectoryLog);
if numFrames == 0
    return;
end

for k = 1:numFrames
    frame = trajectoryLog.Frames(k);
    if ~isfield(frame, 'Targets') || isempty(frame.Targets)
        continue;
    end

    frameTime = frame.Time;
    for i = 1:numel(frame.Targets)
        t = frame.Targets(i);
        targetId = t.ID;
        if isKey(cache, targetId)
            history = cache(targetId);
        else
            history = emptyTargetHistory(numFrames);
            history.RowCount = 0;
            cache(targetId) = history;
            history = cache(targetId);
        end

        row = history.RowCount + 1;
        history.Time(row, 1) = frameTime;
        history.Position(row, :) = t.Position(:).';
        history.Velocity(row, :) = t.Velocity(:).';
        history.Acceleration(row, :) = t.Acceleration(:).';
        history.State(row, 1) = string(t.State);
        history.Visible(row, 1) = logical(t.Visible);
        history.RCS(row, 1) = t.RCS;
        history.RowCount = row;
        cache(targetId) = history;
    end
end

keysList = cache.keys;
for i = 1:numel(keysList)
    targetId = keysList{i};
    history = finalizeTargetHistory(cache(targetId));
    cache(targetId) = history;
end
end

function history = emptyTargetHistory(capacity)
history.Time = zeros(capacity, 1);
history.Position = zeros(capacity, 3);
history.Velocity = zeros(capacity, 3);
history.Acceleration = zeros(capacity, 3);
history.State = strings(capacity, 1);
history.Visible = false(capacity, 1);
history.RCS = zeros(capacity, 1);
history.RowCount = 0;
end

function history = finalizeTargetHistory(history)
rowCount = history.RowCount;
history.Time = history.Time(1:rowCount, :);
history.Position = history.Position(1:rowCount, :);
history.Velocity = history.Velocity(1:rowCount, :);
history.Acceleration = history.Acceleration(1:rowCount, :);
history.State = history.State(1:rowCount, :);
history.Visible = history.Visible(1:rowCount, :);
history.RCS = history.RCS(1:rowCount, :);
history = rmfield(history, 'RowCount');
end
