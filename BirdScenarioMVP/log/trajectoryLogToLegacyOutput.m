function output = trajectoryLogToLegacyOutput(trajectoryLog, config)
% trajectoryLogToLegacyOutput - Преобразовать TrajectoryLog в массив структур legacy output.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct = struct()
end

if ~isfield(trajectoryLog, 'Frames') || isempty(trajectoryLog.Frames)
    output = struct([]);
    return;
end

if hasStoredLegacyExport(trajectoryLog)
    numFrames = numel(trajectoryLog.Frames);
    output = repmat(trajectoryLog.Frames(1).LegacyExport, 1, numFrames);
    for k = 1:numFrames
        output(k) = trajectoryLog.Frames(k).LegacyExport;
    end
    return;
end

if isempty(fieldnames(config))
    error('trajectoryLogToLegacyOutput:MissingConfig', ...
        'config is required when TrajectoryLog frames do not contain LegacyExport.');
end

output = rebuildLegacyOutputFromLog(trajectoryLog, config);
end

function tf = hasStoredLegacyExport(trajectoryLog)
tf = isfield(trajectoryLog.Frames(1), 'LegacyExport');
end
