function target = updateGroundKinematics(target, config, dt)
% updateGroundKinematics - Интеграция движения наземного транспорта с ограничениями.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if ismember(string(target.State), ["Idle", "Stop"])
    target.Position(3) = 0;
    target.Velocity = zeros(3, 1);
    target.Acceleration = zeros(3, 1);
    target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
    return;
end

desiredVel = target.Payload.DesiredVelocity(:);
desiredVel(3) = 0;
velError = desiredVel - target.Velocity(:);
target.Acceleration = velError / max(dt, 1e-3);

accelNorm = norm(target.Acceleration(1:2));
maxAccel = config.groundVehicle.maxAcceleration;
if accelNorm > maxAccel
    target.Acceleration(1:2) = target.Acceleration(1:2) * (maxAccel / accelNorm);
end
target.Acceleration(3) = 0;

target.Velocity = target.Velocity + target.Acceleration * dt;
target = applyGroundMotionLimits(target, config, dt);
target.Position = target.Position + target.Velocity * dt;
target = applyGroundMotionLimits(target, config, dt);
target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
end
