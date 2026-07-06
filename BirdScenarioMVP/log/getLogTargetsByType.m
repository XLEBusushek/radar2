function targets = getLogTargetsByType(trajectoryLog, className, subtype)
% getLogTargetsByType - Collect targets of a type across all frames (last frame IDs).
arguments
    trajectoryLog (1, 1) struct
    className (1, 1) string
    subtype (1, 1) string = ""
end

if ~isfield(trajectoryLog, 'Frames') || isempty(trajectoryLog.Frames)
    targets = struct([]);
    return;
end

lastFrame = trajectoryLog.Frames(end);
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
