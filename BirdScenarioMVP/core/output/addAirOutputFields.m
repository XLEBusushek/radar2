function targetOut = addAirOutputFields(targetOut, target)
% addAirOutputFields - Quadcopter and fixed-wing shared air output fields.
payload = target.Payload;

targetOut.WaypointIndex = getPayloadField(payload, 'CurrentWaypointIndex', nan);
targetOut.DistanceToWaypoint = getPayloadField(payload, 'DistanceToWaypoint', nan);
targetOut.MissionComplete = getPayloadField(payload, 'MissionComplete', false);
targetOut.HomePosition = getPayloadField(payload, 'HomePosition', nan(3, 1));
targetOut.CurrentWaypoint = getPayloadField(payload, 'CurrentWaypoint', nan(3, 1));
targetOut.NoProgressTime = getPayloadField(payload, 'NoProgressTime', nan);
targetOut.ForceDirectToWaypoint = getPayloadField(payload, 'ForceDirectToWaypoint', false);
targetOut.TotalXYExcursion = getPayloadField(payload, 'TotalXYExcursion', nan);
targetOut.MaxAltitudeReached = getPayloadField(payload, 'MaxAltitudeReached', nan);
targetOut.MinAltitudeReached = getPayloadField(payload, 'MinAltitudeReached', nan);
targetOut.LastNavigationEvent = string(getPayloadField(payload, 'LastNavigationEvent', ""));

if target.Subtype == "fixedWingUAV"
    isFW2 = isfield(target, 'Metadata') && isfield(target.Metadata, 'FW2') && target.Metadata.FW2;
    if isFW2
        targetOut = addFixedWing2OutputFields(targetOut, payload);
    else
        targetOut = addFixedWingLegacyOutputFields(targetOut, payload);
    end
end
end
