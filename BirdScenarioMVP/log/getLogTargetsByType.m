function targets = getLogTargetsByType(trajectoryLog, className, subtype)
% getLogTargetsByType - Собрать цели заданного типа из последнего записанного кадра.
arguments
    trajectoryLog (1, 1) struct
    className (1, 1) string
    subtype (1, 1) string = ""
end

if ~isfield(trajectoryLog, 'Frames') || isempty(trajectoryLog.Frames)
    targets = struct([]);
    return;
end

frameIndex = getLogFrameCount(trajectoryLog);
if frameIndex <= 0
    targets = struct([]);
    return;
end

lastFrame = trajectoryLog.Frames(frameIndex);
if ~isfield(lastFrame, 'Targets') || isempty(lastFrame.Targets)
    targets = struct([]);
    return;
end

mask = arrayfun(@(t) t.Type == className, lastFrame.Targets);
if subtype ~= ""
    mask = mask & arrayfun(@(t) t.Subtype == subtype, lastFrame.Targets);
end
targets = lastFrame.Targets(mask);
end
