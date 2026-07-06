function log = trimTrajectoryLog(log)
% trimTrajectoryLog - Drop unused preallocated frame slots.
arguments
    log (1, 1) struct
end

if ~isfield(log, 'FrameCount') || log.FrameCount <= 0
    return;
end

count = log.FrameCount;
if isfield(log, 'Frames') && numel(log.Frames) > count
    log.Frames = log.Frames(1:count);
end
if isfield(log, 'Time') && numel(log.Time) > count
    log.Time = log.Time(1:count);
end
if isfield(log, 'PreallocatedFrameCapacity')
    log.PreallocatedFrameCapacity = count;
end
end
