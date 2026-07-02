function target = advanceFixedWingWaypoint(target, config)
% advanceFixedWingWaypoint - Advance fixed-wing route waypoint.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    return;
end

if ~canSwitchFixedWingWaypoint(target, config)
    return;
end

if target.Payload.CurrentWaypointIndex < size(target.Payload.Waypoints, 1)
    target.Payload.CurrentWaypointIndex = target.Payload.CurrentWaypointIndex + 1;
    target.Payload.CurrentWaypoint = target.Payload.Waypoints(target.Payload.CurrentWaypointIndex, :).';
    target = updateFixedWingFlightLevel(target, config);
    target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
    target.Payload.LastNavigationEvent = "waypointAdvanced";
else
    target.Payload.MissionComplete = true;
    target.Payload.CurrentWaypoint = target.Payload.ExitPoint(:);
    target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
    target.Payload.LastNavigationEvent = "routeComplete";
end

target.Payload.LastWaypointSwitchTime = target.CurrentTime;
target.Payload.TimeOnCurrentLeg = 0;
target.Payload.PreviousNavigationTarget = [];
target.Payload.PreviousLookaheadPoint = [];

target.Payload.DistanceToWaypoint = computeFixedWingWaypointDistance(target);
if isfield(config.fixedWing, 'navigation') && isfield(config.fixedWing.navigation, 'arrivalRadius')
    target.Payload.WaypointArrivalRadius = config.fixedWing.navigation.arrivalRadius;
else
    target.Payload.WaypointArrivalRadius = config.fixedWing.waypointArrivalRadius;
end
end
