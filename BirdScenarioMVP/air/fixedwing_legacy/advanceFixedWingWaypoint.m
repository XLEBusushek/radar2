function target = advanceFixedWingWaypoint(target, config)
% advanceFixedWingWaypoint - Перейти к следующей точке маршрута fixed-wing.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    return;
end

if (isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive) || ...
        string(target.State) == "BorderAvoidance"
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
if isfield(target.Payload, 'ActiveLegDirection') && ~isempty(target.Payload.ActiveLegDirection)
    target.Payload.PreviousLegDirection = target.Payload.ActiveLegDirection;
end
target.Payload.LegTransitionActive = true;
target.Payload.LegTransitionStartTime = target.CurrentTime;
target.Payload.LegTransitionDuration = getFixedWingNavConfigValue(config, ...
    'legTransitionDuration', '', 8);

target = initializeFixedWingActiveLeg(target, config);
if isfield(config.fixedWing, 'navigation') && isfield(config.fixedWing.navigation, 'arrivalRadius')
    target.Payload.WaypointArrivalRadius = config.fixedWing.navigation.arrivalRadius;
else
    target.Payload.WaypointArrivalRadius = config.fixedWing.waypointArrivalRadius;
end
end
