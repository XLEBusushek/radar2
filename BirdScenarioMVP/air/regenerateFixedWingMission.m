function target = regenerateFixedWingMission(target, config)
% regenerateFixedWingMission - Assign a new in-bounds patrol route from current position.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

heading = target.Payload.CurrentHeading;
if isnan(heading)
    heading = atan2(target.Velocity(2), target.Velocity(1));
end

mission = generateFixedWingMission(target.Position, heading, config);
target.Payload.Waypoints = mission.Waypoints;
target.Payload.CurrentWaypointIndex = mission.CurrentWaypointIndex;
target.Payload.CurrentWaypoint = mission.CurrentWaypoint;
target.Payload.WaypointArrivalRadius = mission.WaypointArrivalRadius;
target.Payload.ExitPoint = mission.ExitPoint;
target.Payload.FinalStrategy = mission.FinalStrategy;
target.Payload.MissionComplete = false;
target.Payload.FinalPhase = false;
target.Payload.FinalPhaseStarted = false;
target.Payload.FinalMissionCompleted = false;
target.Payload.TimeInFinalPhase = 0;
target.Payload.ForceDirectToWaypoint = false;
target.Payload.CornerCuttingActive = false;
target.Payload.LastNavigationEvent = "newRoute";

if string(target.State) ~= "Cruise"
    target = transitionFixedWingState(target, "Cruise", "newRoute", config);
end
end
