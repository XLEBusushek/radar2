function target = updateBorderAvoidance(target, config, dt)
% updateBorderAvoidance - Вернуться внутрь Safe Zone, затем возобновить миссию.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

zoneInfo = classifyFixedWingZone(target.Position, config);
target.Payload.NavigationMode = "BorderAvoidance";

if isempty(target.Payload.RecoveryTarget)
    target.Payload.RecoveryTarget = computeRecoveryTarget(target, config, "borderFollowing");
    target.Payload.RecoveryReason = "borderFollowing";
end

recoveryTarget = target.Payload.RecoveryTarget(:);
target.Payload.NavigationLookaheadPoint = recoveryTarget;
target.Payload.CurrentWaypoint = recoveryTarget;
target.Payload.CornerCuttingActive = false;
target.Payload.ForceDirectToWaypoint = true;
target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
target.Payload.DesiredSpeed = max(mean(config.fixedWing.cruiseSpeedRange), config.fixedWing.minSpeed);
target.Payload.LastNavigationEvent = "borderAvoidance";

if zoneInfo.InSafeZone && norm(target.Position(1:2) - recoveryTarget(1:2)) < 200
    target.Payload.RecoveryTarget = [];
    target.Payload.RecoveryReason = "";
    target.Payload.BorderFollowingTime = 0;
    target.Payload.BorderFollowing = false;
    target.Payload.NavigationMode = "Mission";
    if string(target.State) == "BorderAvoidance"
        target = transitionFixedWingState(target, "Cruise", "borderAvoidanceComplete", config);
    end
end
end
