function target = fw2_updateMotion(target, config, dt)
% fw2_updateMotion - Integrate position from heading, speed profile, and climb rate.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

prevVelocity = target.Velocity(:);

horizontalSpeed = target.Payload.CurrentSpeed;
vx = horizontalSpeed * cos(target.Payload.CurrentHeading);
vy = horizontalSpeed * sin(target.Payload.CurrentHeading);
vz = target.Payload.DesiredClimbRate;

target.Velocity = [vx; vy; vz];
target.Position = target.Position + target.Velocity * dt;
target.Acceleration = (target.Velocity - prevVelocity) / dt;
end
