function canSwitch = canSwitchFixedWingWaypoint(target, config)
% canSwitchFixedWingWaypoint - Cooldown and min leg time before waypoint advance.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

canSwitch = true;
if ~isfield(config.fixedWing, 'antiBounce') || ~config.fixedWing.antiBounce.enabled
    return;
end

ab = config.fixedWing.antiBounce;
arrivalRadius = target.Payload.WaypointArrivalRadius;
if isfield(config.fixedWing, 'navigation') && isfield(config.fixedWing.navigation, 'arrivalRadius')
    arrivalRadius = config.fixedWing.navigation.arrivalRadius;
end

dist = computeFixedWingWaypointDistance(target);
inArrival = dist <= arrivalRadius;
if isfield(config.fixedWing, 'navigation') && isfield(config.fixedWing.navigation, 'cornerCuttingEnabled') && ...
        config.fixedWing.navigation.cornerCuttingEnabled && ...
        isfield(target.Payload, 'CornerCuttingActive') && target.Payload.CornerCuttingActive && ...
        isfield(config.fixedWing.navigation, 'cornerCuttingRadius')
    inArrival = inArrival || dist <= config.fixedWing.navigation.cornerCuttingRadius;
    if isfield(config.fixedWing.navigation, 'arcTurnEnabled') && config.fixedWing.navigation.arcTurnEnabled
        inArrival = inArrival || dist <= getFixedWingDesiredTurnRadius(config) * 1.4;
    end
end

if inArrival
    return;
end

if isfield(target.Payload, 'TimeOnCurrentLeg') && target.Payload.TimeOnCurrentLeg < ab.minTimeOnLeg
    canSwitch = false;
    return;
end

if isfield(target.Payload, 'LastWaypointSwitchTime') && ...
        target.CurrentTime - target.Payload.LastWaypointSwitchTime < ab.waypointSwitchCooldown
    canSwitch = false;
end
end
