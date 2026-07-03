function target = fw2_limitClimbAngle(target, config)
% fw2_limitClimbAngle - Limit climb/descent angle from horizontal speed.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

ap = config.fixedWing2.altitudeProfile;
speed = target.Payload.CurrentSpeed;

if speed < 1e-6
    target.Payload.ClimbAngleDeg = 0;
    target.Payload.DesiredClimbRate = 0;
    return;
end

maxVzClimb = speed * tan(deg2rad(ap.maxClimbAngleDeg));
maxVzDesc = speed * tan(deg2rad(ap.maxDescentAngleDeg));
target.Payload.DesiredClimbRate = min(max(target.Payload.DesiredClimbRate, -maxVzDesc), maxVzClimb);
target.Payload.ClimbAngleDeg = atan2(target.Payload.DesiredClimbRate, speed) * 180 / pi;
end
