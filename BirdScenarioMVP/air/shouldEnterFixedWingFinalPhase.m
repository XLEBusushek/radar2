function enter = shouldEnterFixedWingFinalPhase(target, config)
% shouldEnterFixedWingFinalPhase - Detect when fixed-wing mission enters final phase.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

enter = false;
if ~isfield(config, 'fixedWing') || ~isfield(config.fixedWing, 'finalPhase') || ...
        ~config.fixedWing.finalPhase.enabled
    return;
end
if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    return;
end
if isfield(target.Payload, 'FinalMissionCompleted') && target.Payload.FinalMissionCompleted
    return;
end
if isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive && ...
        isfield(target.Payload, 'OutsideBoundary') && target.Payload.OutsideBoundary
    return;
end

fp = config.fixedWing.finalPhase;
numWaypoints = size(target.Payload.Waypoints, 1);
waypointIndex = target.Payload.CurrentWaypointIndex;

if isfield(target.Payload, 'MissionComplete') && target.Payload.MissionComplete
    enter = true;
    return;
end

if numWaypoints > 0
    remaining = numWaypoints - waypointIndex + 1;
    if remaining <= fp.waypointsRemainingTrigger
        enter = true;
        return;
    end
end

if numWaypoints > 1
    progress = (waypointIndex - 1) / (numWaypoints - 1);
    if progress >= fp.routeProgressThreshold
        enter = true;
        return;
    end
end

if waypointIndex >= numWaypoints
    arrivalRadius = target.Payload.WaypointArrivalRadius;
    if isfield(config.fixedWing, 'navigation') && isfield(config.fixedWing.navigation, 'arrivalRadius')
        arrivalRadius = config.fixedWing.navigation.arrivalRadius;
    end
    distance = computeFixedWingWaypointDistance(target);
    if distance <= arrivalRadius
        enter = true;
    end
end
end
