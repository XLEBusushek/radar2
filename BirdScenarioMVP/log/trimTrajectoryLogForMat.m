function log = trimTrajectoryLogForMat(log)
% trimTrajectoryLogForMat - Drop heavy log fields before MAT export.
arguments
    log (1, 1) struct
end

if isfield(log, 'TargetHistoryCache')
    log = rmfield(log, 'TargetHistoryCache');
end
if isfield(log, 'CsvRows')
    log = rmfield(log, 'CsvRows');
end
if isfield(log, 'CsvRowCount')
    log = rmfield(log, 'CsvRowCount');
end
if ~isfield(log, 'Frames')
    return;
end

for k = 1:numel(log.Frames)
    if ~isfield(log.Frames(k), 'Targets')
        continue;
    end
    targets = log.Frames(k).Targets;
    for t = 1:numel(targets)
        targets(t) = stripHeavyTargetLogFields(targets(t));
    end
    log.Frames(k).Targets = targets;
end
end

function target = stripHeavyTargetLogFields(target)
heavyFields = {'Payload', 'MetadataSnapshot', 'BehaviorSnapshot'};
for i = 1:numel(heavyFields)
    name = heavyFields{i};
    if isfield(target, name)
        target = rmfield(target, name);
    end
end
end
