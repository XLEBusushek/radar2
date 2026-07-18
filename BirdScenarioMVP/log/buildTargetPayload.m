function payload = buildTargetPayload(target, config)
% buildTargetPayload - Снимок Payload цели для TrajectoryLog.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

if ~shouldStorePayload(config)
    payload = struct();
    return;
end

if shouldStoreFullPayload(config) && isfield(target, 'Payload')
    payload = target.Payload;
else
    payload = buildCompactTargetPayload(target);
end

payload.TargetSeed = nan;
if isfield(target, 'Metadata') && isfield(target.Metadata, 'RandomSeed')
    payload.TargetSeed = target.Metadata.RandomSeed;
end
end

function payload = buildCompactTargetPayload(target)
switch string(target.Class)
    case "bird"
        payload = buildBirdPayload(target);
    case "air"
        if target.Subtype == "quadcopter"
            payload = buildQuadPayload(target);
        elseif target.Subtype == "fixedWingUAV"
            payload = buildFixedWingPayload(target);
        else
            payload = struct();
        end
    case "ground"
        payload = buildGroundPayload(target);
    otherwise
        payload = struct();
end

if isfield(target, 'Payload')
    p = target.Payload;
    if isfield(p, 'TransitionCount')
        payload.TransitionCount = p.TransitionCount;
    end
    if isfield(p, 'LastTransitionReason')
        payload.LastTransitionReason = p.LastTransitionReason;
    end
end
end

function tf = shouldStoreFullPayload(config)
if ~shouldStorePayload(config)
    tf = false;
    return;
end

if isfield(config, 'log') && isfield(config.log, 'storeFullPayload')
    tf = logical(config.log.storeFullPayload);
else
    tf = true;
end
end
