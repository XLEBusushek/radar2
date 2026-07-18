function fixedWingUAVs = fw2_createFixedWingUAVs(config, startId)
% fw2_createFixedWingUAVs - Создать популяцию fixed-wing2 UAV.
arguments
    config (1, 1) struct
    startId (1, 1) {mustBePositive, mustBeInteger} = 1
end

if ~isfield(config, 'fixedWing2') || ~isfield(config.fixedWing2, 'count')
    error('fw2_createFixedWingUAVs:MissingField', 'config.fixedWing2.count is required.');
end

numTargets = config.fixedWing2.count;
if numTargets == 0
    fixedWingUAVs = struct([]);
    return;
end

for i = 1:numTargets
    fixedWingUAVs(i) = fw2_createFixedWingTarget(startId + i - 1, config); %#ok<AGROW>
end
end
