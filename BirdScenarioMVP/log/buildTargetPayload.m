function payload = buildTargetPayload(target, config)
% buildTargetPayload - Dispatch payload builder by target class/subtype.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

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
payload.TargetSeed = nan;
if isfield(target, 'Metadata') && isfield(target.Metadata, 'RandomSeed')
    payload.TargetSeed = target.Metadata.RandomSeed;
end
end
