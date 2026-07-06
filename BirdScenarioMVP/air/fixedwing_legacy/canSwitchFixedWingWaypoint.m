function canSwitch = canSwitchFixedWingWaypoint(target, config)
% canSwitchFixedWingWaypoint - Leg progress and min time before waypoint advance.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

canSwitch = false;
arrivalRadius = target.Payload.WaypointArrivalRadius;
if isfield(config.fixedWing, 'navigation') && isfield(config.fixedWing.navigation, 'arrivalRadius')
    arrivalRadius = config.fixedWing.navigation.arrivalRadius;
end

dist = computeFixedWingWaypointDistance(target);
inArrival = dist <= arrivalRadius;

minLegTime = getFixedWingNavConfigValue(config, 'minLegTime', 'minTimeOnLeg', 12);
minProgress = getFixedWingNavConfigValue(config, 'minLegProgressForSwitch', '', 0.75);

if inArrival
    canSwitch = true;
    return;
end

if isfield(target.Payload, 'TimeOnCurrentLeg') && target.Payload.TimeOnCurrentLeg < minLegTime
    return;
end

if isfield(target.Payload, 'ActiveLegProgress') && ...
        target.Payload.ActiveLegProgress >= minProgress
    canSwitch = true;
    return;
end

if isfield(target.Payload, 'ActiveLegStart') && ~isempty(target.Payload.ActiveLegStart)
    legStart = target.Payload.ActiveLegStart(:);
    legDirection = target.Payload.ActiveLegDirection(:);
    legLength = target.Payload.ActiveLegLength;
    sAlong = dot(target.Position(1:2) - legStart(1:2), legDirection);
    if sAlong >= legLength - max(arrivalRadius * 0.5, 20)
        canSwitch = true;
        return;
    end
end

cooldown = getFixedWingNavConfigValue(config, 'waypointSwitchCooldown', 'waypointSwitchCooldown', 8);
if isfield(target.Payload, 'LastWaypointSwitchTime') && ...
        target.CurrentTime - target.Payload.LastWaypointSwitchTime < cooldown
    canSwitch = false;
end
end
