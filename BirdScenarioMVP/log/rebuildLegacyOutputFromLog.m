function output = rebuildLegacyOutputFromLog(trajectoryLog, config)
% rebuildLegacyOutputFromLog - Reconstruct legacy output[] from TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
end

if ~isfield(trajectoryLog, 'Frames') || isempty(trajectoryLog.Frames)
    output = struct([]);
    return;
end

numFrames = numel(trajectoryLog.Frames);
output = collectOutputFromLogFrame(trajectoryLog.Frames(1), trajectoryLog, config);
output = repmat(output, 1, numFrames);
for k = 1:numFrames
    output(k) = collectOutputFromLogFrame(trajectoryLog.Frames(k), trajectoryLog, config);
end
end
