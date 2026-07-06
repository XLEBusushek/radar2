function tf = shouldStorePayload(config)
% shouldStorePayload - Whether TrajectoryLog stores per-target Payload.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'storePayload')
    tf = logical(config.log.storePayload);
else
    tf = true;
end
end
