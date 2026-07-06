function target = updateQuadcopterKinematics(target, config, dt)
% updateQuadcopterKinematics - Integrate quadcopter motion with limits.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if string(target.State) == "Idle"
    target.Position(3) = 0;
    target.Velocity = zeros(3, 1);
    target.Acceleration = zeros(3, 1);
    target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
    return;
end

desiredVel = target.Payload.DesiredVelocity(:);
velError = desiredVel - target.Velocity;
target.Acceleration = velError / max(dt, 1e-3);

accelNorm = norm(target.Acceleration);
maxAccel = config.quadcopter.maxAcceleration;
if accelNorm > maxAccel
    target.Acceleration = target.Acceleration * (maxAccel / accelNorm);
end

target.Velocity = target.Velocity + target.Acceleration * dt;
target.Position = target.Position + target.Velocity * dt;

target = applyQuadcopterMotionLimits(target, config);

target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
end
