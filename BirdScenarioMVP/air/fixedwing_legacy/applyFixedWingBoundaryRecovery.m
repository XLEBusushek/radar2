function target = applyFixedWingBoundaryRecovery(target, config, dt)
% applyFixedWingBoundaryRecovery - Navigate smoothly back inside Safe Zone.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if isempty(target.Payload.RecoveryTarget)
    if isempty(target.Payload.BoundaryRecoveryTarget)
        target.Payload.RecoveryTarget = computeRecoveryTarget(target, config, ...
            string(getPayloadReason(target)));
        target.Payload.BoundaryRecoveryTarget = target.Payload.RecoveryTarget;
    else
        target.Payload.RecoveryTarget = target.Payload.BoundaryRecoveryTarget;
    end
end

recoveryTarget = target.Payload.RecoveryTarget(:);
target.Payload.NavigationLookaheadPoint = recoveryTarget;
target.Payload.CurrentWaypoint = recoveryTarget;
target.Payload.CornerCuttingActive = false;
target.Payload.NavigationMode = "Recovery";
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

function reason = getPayloadReason(target)
if isfield(target.Payload, 'RecoveryReason') && strlength(string(target.Payload.RecoveryReason)) > 0
    reason = string(target.Payload.RecoveryReason);
else
    reason = "warningZone";
end
end
