function target = applyGroundMotionLimits(target, config, dt)
% applyGroundMotionLimits - Enforce speed, acceleration, turn rate, bounds and Z.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive} = 1
end

gv = config.groundVehicle;

speed = norm(target.Velocity(1:2));
maxSpeed = gv.speedRange(2);
if speed > maxSpeed
    target.Velocity(1:2) = target.Velocity(1:2) * (maxSpeed / speed);
end

accelNorm = norm(target.Acceleration(1:2));
if accelNorm > gv.maxAcceleration
    target.Acceleration(1:2) = target.Acceleration(1:2) * (gv.maxAcceleration / accelNorm);
end

target.Velocity = limitTurnRate(target.Velocity, target.Payload.DesiredVelocity, config, dt);
target.Velocity(3) = 0;
target.Acceleration(3) = 0;

target.Position = enforceWorldBounds(target.Position, config.world.size);
heightRange = gv.heightRange;
target.Position(3) = min(max(target.Position(3), heightRange(1)), heightRange(2));
if string(target.State) ~= "LeaveRoad"
    target.Position(3) = 0;
end

if ismember(string(target.State), ["Idle", "Stop"])
    target.Velocity = zeros(3, 1);
    target.Acceleration = zeros(3, 1);
end
end

function velocity = limitTurnRate(currentVelocity, desiredVelocity, config, dt)
velocity = currentVelocity(:);
currentSpeed = norm(currentVelocity(1:2));
desiredSpeed = norm(desiredVelocity(1:2));
if currentSpeed < 1e-6 || desiredSpeed < 1e-6
    velocity = currentVelocity(:);
    return;
end

currentAngle = atan2(currentVelocity(2), currentVelocity(1));
desiredAngle = atan2(desiredVelocity(2), desiredVelocity(1));
delta = wrapToPiLocal(desiredAngle - currentAngle);
maxDelta = deg2rad(config.groundVehicle.maxTurnRateDeg) * dt;
newAngle = currentAngle + min(max(delta, -maxDelta), maxDelta);
speed = min(currentSpeed, config.groundVehicle.speedRange(2));
velocity = [speed * cos(newAngle); speed * sin(newAngle); 0];
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
