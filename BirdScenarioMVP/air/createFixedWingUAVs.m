function fixedWingUAVs = createFixedWingUAVs(config, startId)
% createFixedWingUAVs - Create fixed-wing UAV population with unique IDs.
arguments
    config (1, 1) struct
    startId (1, 1) {mustBePositive, mustBeInteger} = 1
end

if ~isfield(config, 'fixedWing') || ~isfield(config.fixedWing, 'count')
    error('createFixedWingUAVs:MissingField', 'config.fixedWing.count is required.');
end

numTargets = config.fixedWing.count;
if numTargets == 0
    fixedWingUAVs = struct([]);
    return;
end

for i = 1:numTargets
    fixedWingUAVs(i) = createFixedWingTarget(startId + i - 1, config); %#ok<AGROW>
end
end
