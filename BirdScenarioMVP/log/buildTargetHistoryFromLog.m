function history = buildTargetHistoryFromLog(trajectoryLog, targetId)
% buildTargetHistoryFromLog - Reconstruct target.History-like series from log.
arguments
    trajectoryLog (1, 1) struct
    targetId (1, 1) double
end

if isfield(trajectoryLog, 'TargetHistoryCache') && ...
        isa(trajectoryLog.TargetHistoryCache, 'containers.Map') && ...
        isKey(trajectoryLog.TargetHistoryCache, targetId)
    history = trajectoryLog.TargetHistoryCache(targetId);
    return;
end

history = emptyTargetHistoryOutput();
numFrames = getLogFrameCount(trajectoryLog);
if numFrames == 0
    return;
end

row = 0;
for k = 1:numFrames
    frame = trajectoryLog.Frames(k);
    if ~isfield(frame, 'Targets') || isempty(frame.Targets)
        continue;
    end
    idx = find([frame.Targets.ID] == targetId, 1);
    if isempty(idx)
        continue;
    end
    t = frame.Targets(idx);
    row = row + 1;
    history.Time(row, 1) = frame.Time;
    history.Position(row, :) = t.Position(:).';
    history.Velocity(row, :) = t.Velocity(:).';
    history.Acceleration(row, :) = t.Acceleration(:).';
    history.State(row, 1) = string(t.State);
    history.Visible(row, 1) = logical(t.Visible);
    history.RCS(row, 1) = t.RCS;
end

if row == 0
    history = emptyTargetHistoryOutput();
    return;
end

history.Time = history.Time(1:row, :);
history.Position = history.Position(1:row, :);
history.Velocity = history.Velocity(1:row, :);
history.Acceleration = history.Acceleration(1:row, :);
history.State = history.State(1:row, :);
history.Visible = history.Visible(1:row, :);
history.RCS = history.RCS(1:row, :);
end

function history = emptyTargetHistoryOutput()
history.Time = zeros(0, 1);
history.Position = zeros(0, 3);
history.Velocity = zeros(0, 3);
history.Acceleration = zeros(0, 3);
history.State = strings(0, 1);
history.Visible = zeros(0, 1);
history.RCS = zeros(0, 1);
end
