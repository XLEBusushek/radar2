function output = trajectoryLogToLegacyOutput(trajectoryLog)
% trajectoryLogToLegacyOutput - Convert TrajectoryLog to legacy output struct array.
arguments
    trajectoryLog (1, 1) struct
end

if ~isfield(trajectoryLog, 'Frames') || isempty(trajectoryLog.Frames)
    output = struct([]);
    return;
end

numFrames = numel(trajectoryLog.Frames);
output = repmat(trajectoryLog.Frames(1).LegacyExport, 1, numFrames);
for k = 1:numFrames
    output(k) = trajectoryLog.Frames(k).LegacyExport;
end
end
