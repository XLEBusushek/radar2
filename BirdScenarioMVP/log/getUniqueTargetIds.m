function ids = getUniqueTargetIds(trajectoryLog, className, subtype)
% getUniqueTargetIds - Collect unique target IDs from TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    className (1, 1) string = ""
    subtype (1, 1) string = ""
end

ids = [];
if ~isfield(trajectoryLog, 'Frames') || isempty(trajectoryLog.Frames)
    return;
end

for k = 1:numel(trajectoryLog.Frames)
    frame = trajectoryLog.Frames(k);
    if ~isfield(frame, 'Targets') || isempty(frame.Targets)
        continue;
    end
    for i = 1:numel(frame.Targets)
        t = frame.Targets(i);
        if className ~= "" && t.Type ~= className
            continue;
        end
        if subtype ~= "" && t.Subtype ~= subtype
            continue;
        end
        ids = [ids; t.ID]; %#ok<AGROW>
    end
end
ids = unique(ids);
end
