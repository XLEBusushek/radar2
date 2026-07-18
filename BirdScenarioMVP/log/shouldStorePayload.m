function tf = shouldStorePayload(config)
% shouldStorePayload - Сохранять ли TrajectoryLog Payload для каждой цели.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'storePayload')
    tf = logical(config.log.storePayload);
else
    tf = true;
end
end
