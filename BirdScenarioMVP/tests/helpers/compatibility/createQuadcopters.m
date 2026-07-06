function quadcopters = createQuadcopters(config, startId)
% createQuadcopters - Compatibility factory (use createTargets instead).
arguments
    config (1, 1) struct
    startId (1, 1) {mustBePositive, mustBeInteger} = 1
end

if ~isfield(config, 'quadcopter') || ~isfield(config.quadcopter, 'count')
    error('createQuadcopters:MissingField', 'config.quadcopter.count is required.');
end

numQuadcopters = config.quadcopter.count;
if numQuadcopters == 0
    quadcopters = struct([]);
    return;
end

for i = 1:numQuadcopters
    quadcopters(i) = createQuadcopterTarget(startId + i - 1, config);
end
end
