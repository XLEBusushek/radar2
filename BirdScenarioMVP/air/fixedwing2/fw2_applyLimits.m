function target = fw2_applyLimits(target, config, dt)
% fw2_applyLimits - Финальное ограничение скорости и высотного конверта.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

fw2 = config.fixedWing2;
ap = fw2.altitudeProfile;

target.Payload.CurrentSpeed = min(max(target.Payload.CurrentSpeed, fw2.speed.minSpeed), fw2.speed.maxSpeed);
target.Payload.TargetSpeed = min(max(target.Payload.TargetSpeed, fw2.speed.minSpeed), fw2.speed.maxSpeed);

altRange = ap.levelRange;
target.Payload.TargetFlightLevel = min(max(target.Payload.TargetFlightLevel, altRange(1)), altRange(2));
target.Payload.CurrentFlightLevel = min(max(target.Payload.CurrentFlightLevel, altRange(1)), altRange(2));
target.Payload.FlightLevel = target.Payload.CurrentFlightLevel;

target.Payload.DesiredClimbRate = min(max(target.Payload.DesiredClimbRate, ...
    -ap.maxVerticalSpeed), ap.maxVerticalSpeed);
target.Velocity(3) = target.Payload.DesiredClimbRate;
end
