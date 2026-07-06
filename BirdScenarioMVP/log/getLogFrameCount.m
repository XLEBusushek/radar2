function count = getLogFrameCount(trajectoryLog)
% getLogFrameCount - Number of recorded frames in TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
end

if isfield(trajectoryLog, 'FrameCount') && trajectoryLog.FrameCount > 0
    count = trajectoryLog.FrameCount;
    return;
end

if isfield(trajectoryLog, 'Frames')
    count = numel(trajectoryLog.Frames);
else
    count = 0;
end
end
