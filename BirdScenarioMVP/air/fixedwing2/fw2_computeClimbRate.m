function target = fw2_computeClimbRate(target, config)
% fw2_computeClimbRate - Плавная вертикальная команда к целевому эшелону.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

ap = config.fixedWing2.altitudeProfile;
target.Payload.AltitudeError = target.Payload.TargetFlightLevel - target.Position(3);

if abs(target.Payload.AltitudeError) < ap.altitudeTolerance
    target.Payload.DesiredClimbRate = 0;
else
    target.Payload.DesiredClimbRate = ap.altitudeCommandGain * target.Payload.AltitudeError;
end

target.Payload.DesiredClimbRate = min(max(target.Payload.DesiredClimbRate, ...
    -ap.maxVerticalSpeed), ap.maxVerticalSpeed);
end
