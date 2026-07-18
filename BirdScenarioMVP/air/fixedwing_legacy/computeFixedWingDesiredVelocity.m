function target = computeFixedWingDesiredVelocity(target, config, dt)
% computeFixedWingDesiredVelocity - Команда на основе курса для fixed-wing UAV.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

fw = config.fixedWing;
state = string(target.State);

if isempty(target.Payload.DesiredSpeed) || target.Payload.DesiredSpeed < fw.minSpeed
    target.Payload.DesiredSpeed = mean(fw.cruiseSpeedRange);
end

if state == "Loiter"
    target.Payload.LoiterAngle = target.Payload.LoiterAngle + ...
        target.Payload.DesiredSpeed / max(target.Payload.LoiterRadius, 1) * ...
        target.Payload.LoiterDirection * dt;
end

useAntiBounce = isfield(fw, 'antiBounce') && fw.antiBounce.enabled;
if useAntiBounce
    target = applyFixedWingAntiBounce(target, config, dt);
else
    if isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive && ...
            ~isempty(target.Payload.BoundaryRecoveryTarget)
        target.Payload.NavigationLookaheadPoint = target.Payload.BoundaryRecoveryTarget(:);
        targetPoint = target.Payload.NavigationLookaheadPoint(:);
    else
        target = computeFixedWingLookaheadPoint(target, config);
        targetPoint = target.Payload.NavigationLookaheadPoint(:);
    end
    deltaXY = targetPoint(1:2) - target.Position(1:2);
    if norm(deltaXY) > 1e-6
        targetHeading = atan2(deltaXY(2), deltaXY(1));
    else
        targetHeading = target.Payload.CurrentHeading;
    end
    target = applyFixedWingHeadingSmoothing(target, targetHeading, config, dt);
end

switch state
    case "Dive"
        target.Payload.TargetFlightLevel = target.Payload.DiveTargetAltitude;
    case "Recover"
        if target.Payload.TargetFlightLevel < fw.flightLevel.levelRange(1)
            target = initializeFixedWingFlightLevel(target, config);
        end
    case "ExitArea"
        target.Payload.DesiredSpeed = max(mean(fw.cruiseSpeedRange), fw.minSpeed);
    otherwise
        if ~isfield(target.Payload, 'TargetFlightLevel') || isempty(target.Payload.TargetFlightLevel)
            target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
        end
end

target = applyFixedWingSpeedSmoothing(target, config);
target = applyFixedWingAltitudeSmoothing(target, config);
target = computeFixedWingAltitudeCommand(target, config);

heading = target.Payload.CurrentHeading;
horizontalSpeed = target.Payload.SmoothedDesiredSpeed;
vz = target.Payload.DesiredClimbRate;
target.Payload.DesiredVelocity = [cos(heading) * horizontalSpeed; ...
    sin(heading) * horizontalSpeed; vz];
target.Payload.DistanceToWaypoint = computeFixedWingWaypointDistance(target);
end
