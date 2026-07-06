function history = buildTargetHistoryFromLog(trajectoryLog, targetId)
% buildTargetHistoryFromLog - Reconstruct target.History-like series from log.
arguments
    trajectoryLog (1, 1) struct
    targetId (1, 1) double
end

history.Time = zeros(0, 1);
history.Position = zeros(0, 3);
history.Velocity = zeros(0, 3);
history.Acceleration = zeros(0, 3);
history.State = strings(0, 1);
history.Visible = zeros(0, 1);
history.RCS = zeros(0, 1);

if ~isfield(trajectoryLog, 'Frames') || isempty(trajectoryLog.Frames)
    return;
end

for k = 1:numel(trajectoryLog.Frames)
    frame = trajectoryLog.Frames(k);
    if ~isfield(frame, 'Targets') || isempty(frame.Targets)
        continue;
    end
    idx = find([frame.Targets.ID] == targetId, 1);
    if isempty(idx)
        continue;
    end
    t = frame.Targets(idx);
    history.Time(end + 1, 1) = frame.Time;
    history.Position(end + 1, :) = t.Position(:).';
    history.Velocity(end + 1, :) = t.Velocity(:).';
    history.Acceleration(end + 1, :) = t.Acceleration(:).';
    history.State(end + 1, 1) = string(t.State);
    history.Visible(end + 1, 1) = logical(t.Visible);
    history.RCS(end + 1, 1) = t.RCS;
end
end
