function target = computeFixedWingAltitudeCommand(target, config)
% computeFixedWingAltitudeCommand - Command climb rate toward target flight level.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

fl = config.fixedWing.flightLevel;
targetLevel = target.Payload.TargetFlightLevel;
altitudeError = targetLevel - target.Position(3);
target.Payload.AltitudeError = altitudeError;

if abs(altitudeError) < fl.altitudeTolerance
    climbRate = 0;
else
    climbRate = fl.climbGain * altitudeError;
end

horizontalSpeed = norm(target.Velocity(1:2));
if horizontalSpeed < config.fixedWing.minSpeed
    horizontalSpeed = max(target.Payload.SmoothedDesiredSpeed, config.fixedWing.minSpeed);
end
climbRate = limitFixedWingClimbAngle(climbRate, horizontalSpeed, config);

target.Payload.DesiredClimbRate = climbRate;
if horizontalSpeed > 1e-6
    target.Payload.ClimbAngleDeg = rad2deg(atan2(climbRate, horizontalSpeed));
else
    target.Payload.ClimbAngleDeg = 0;
end
end
