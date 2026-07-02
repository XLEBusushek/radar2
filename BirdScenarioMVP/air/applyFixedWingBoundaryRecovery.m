function target = applyFixedWingBoundaryRecovery(target, config, dt)
% applyFixedWingBoundaryRecovery - Navigate smoothly back inside the world bounds.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if isempty(target.Payload.BoundaryRecoveryTarget)
    target.Payload.BoundaryRecoveryTarget = computeBoundaryRecoveryTarget(target, config);
end

recoveryTarget = target.Payload.BoundaryRecoveryTarget(:);
target.Payload.NavigationLookaheadPoint = recoveryTarget;
target.Payload.CurrentWaypoint = recoveryTarget;
target.Payload.CornerCuttingActive = false;
if isfield(target.Payload, 'OutsideBoundary') && target.Payload.OutsideBoundary
    target.Payload.ForceDirectToWaypoint = true;
else
    target.Payload.ForceDirectToWaypoint = false;
end
target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
target.Payload.DesiredSpeed = max(mean(config.fixedWing.cruiseSpeedRange), config.fixedWing.minSpeed);
target.Payload.LastNavigationEvent = "boundaryRecovery";

state = string(target.State);
if ismember(state, ["Loiter", "Dive", "ExitArea", "ApproachExit", "AlignExit", "Exit"])
    target = transitionFixedWingState(target, "Cruise", "boundaryRecovery", config);
end
end
