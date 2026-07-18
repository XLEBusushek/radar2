function target = applyQuadcopterMotionLimits(target, config)
% applyQuadcopterMotionLimits - Ограничить скорость, вертикальную скорость и границы мира.
qc = config.quadcopter;
worldSize = config.world.size;

maxSpeed = qc.speedRange(2);
maxVz = qc.maxVerticalSpeed;

speed = norm(target.Velocity);
if speed > maxSpeed
    target.Velocity = target.Velocity * (maxSpeed / speed);
end

if abs(target.Velocity(3)) > maxVz
    target.Velocity(3) = sign(target.Velocity(3)) * maxVz;
end

accelNorm = norm(target.Acceleration);
if accelNorm > qc.maxAcceleration
    target.Acceleration = target.Acceleration * (qc.maxAcceleration / accelNorm);
end

target.Position = enforceWorldBounds(target.Position, worldSize);

if string(target.State) == "Idle"
    target.Position(3) = 0;
    target.Velocity = zeros(3, 1);
    target.Acceleration = zeros(3, 1);
end

if target.Position(3) < 0
    target.Position(3) = 0;
end
end
