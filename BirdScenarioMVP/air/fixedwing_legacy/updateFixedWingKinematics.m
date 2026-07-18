function target = updateFixedWingKinematics(target, config, dt)
% updateFixedWingKinematics - Интегрировать движение fixed-wing с инерционными ограничениями.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

desiredVel = target.Payload.DesiredVelocity(:);
velError = desiredVel - target.Velocity;
target.Acceleration = velError / max(dt, 1e-3);

accelNorm = norm(target.Acceleration);
maxAccel = config.fixedWing.maxAcceleration;
if accelNorm > maxAccel
    target.Acceleration = target.Acceleration * (maxAccel / accelNorm);
end

target.Velocity = target.Velocity + target.Acceleration * dt;
target = applyFixedWingMotionLimits(target, config, dt);
target.Position = target.Position + target.Velocity * dt;
target = applyFixedWingMotionLimits(target, config, dt);

target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
end
