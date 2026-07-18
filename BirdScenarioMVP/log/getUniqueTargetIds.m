function ids = getUniqueTargetIds(trajectoryLog, className, subtype)
% getUniqueTargetIds - Собрать уникальные ID целей из TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    className (1, 1) string = ""
    subtype (1, 1) string = ""
end

numFrames = getLogFrameCount(trajectoryLog);
if numFrames == 0
    ids = [];
    return;
end

buffer = zeros(numFrames * 32, 1);
count = 0;

for k = 1:numFrames
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
        count = count + 1;
        if count > numel(buffer)
            buffer = [buffer; zeros(numel(buffer), 1)]; %#ok<AGROW>
        end
        buffer(count) = t.ID;
    end
end

if count == 0
    ids = [];
else
    ids = unique(buffer(1:count));
end
end
