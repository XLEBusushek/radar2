function target = limitFixedWingBoundaryVelocity(target, config, dt, preferBoundaryMargin)
% limitFixedWingBoundaryVelocity - Плавная коррекция скорости у границы (без отскока от стены).
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
    preferBoundaryMargin (1, 1) logical = false
end

fw = config.fixedWing;
if ~isfield(fw, 'boundary') || ~fw.boundary.enabled
    return;
end

useSmooth = isfield(fw.boundary, 'smoothVelocityLimit') && fw.boundary.smoothVelocityLimit;
if ~useSmooth
    target = limitOutwardBoundaryVelocityLegacy(target, config, preferBoundaryMargin);
    return;
end

worldSize = config.world.size;
margin = fw.navigation.boundaryMargin;
if preferBoundaryMargin && isfield(fw.boundary, 'margin')
    margin = fw.boundary.margin;
end

pos = target.Position(:);
vel = target.Velocity(:);
velXY = vel(1:2);
speed = norm(velXY);
if speed < 1e-6
    return;
end

[outward, active] = computeOutwardNormal(pos, worldSize, margin);
if ~active
    return;
end

outwardSpeed = dot(velXY, outward);
if outwardSpeed <= 0
    return;
end

velXY = velXY - outwardSpeed * outward;
outputSpeed = max(norm(vel(1:2)), fw.minSpeed);
if norm(velXY) < fw.minSpeed * 0.5
    tangent = [-outward(2); outward(1)];
    if norm(tangent) < 1e-6
        tangent = [1; 0];
    else
        tangent = tangent / norm(tangent);
    end
    desiredHeading = atan2(tangent(2), tangent(1));
else
    desiredHeading = atan2(velXY(2), velXY(1));
end

currentHeading = atan2(vel(2), vel(1));
headingError = wrapToPiLocal(desiredHeading - currentHeading);
R = getFixedWingDesiredTurnRadius(config);
maxTurnRate = deg2rad(fw.boundary.velocityTurnRateDeg);
maxTurnRate = min(maxTurnRate, norm(vel(1:2)) / max(R, 1));
maxDelta = maxTurnRate * dt;
limitedDelta = min(max(headingError, -maxDelta), maxDelta);
newHeading = wrapToPiLocal(currentHeading + limitedDelta);
velXY = [cos(newHeading); sin(newHeading)] * outputSpeed;

target.Velocity(1:2) = velXY;
target.Payload.LastBoundaryEvent = "boundaryVelocitySmoothed";
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end

function [outward, active] = computeOutwardNormal(pos, worldSize, margin)
outward = [0; 0];
active = false;

if pos(1) <= margin
    outward = outward + [-1; 0];
    active = true;
elseif pos(1) >= worldSize(1) - margin
    outward = outward + [1; 0];
    active = true;
end

if pos(2) <= margin
    outward = outward + [0; -1];
    active = true;
elseif pos(2) >= worldSize(2) - margin
    outward = outward + [0; 1];
    active = true;
end

if active && norm(outward) > 1e-6
    outward = outward / norm(outward);
end
end

function target = limitOutwardBoundaryVelocityLegacy(target, config, preferBoundaryMargin)
worldSize = config.world.size;
margin = config.fixedWing.navigation.boundaryMargin;
if preferBoundaryMargin && isfield(config.fixedWing, 'boundary') && ...
        isfield(config.fixedWing.boundary, 'margin')
    margin = config.fixedWing.boundary.margin;
end
pos = target.Position(:);
vel = target.Velocity(:);

if pos(1) <= margin && vel(1) < 0
    vel(1) = abs(vel(1));
elseif pos(1) >= worldSize(1) - margin && vel(1) > 0
    vel(1) = -abs(vel(1));
end

if pos(2) <= margin && vel(2) < 0
    vel(2) = abs(vel(2));
elseif pos(2) >= worldSize(2) - margin && vel(2) > 0
    vel(2) = -abs(vel(2));
end

if norm(vel(1:2)) > 1e-6
    target.Velocity = vel;
end
end
