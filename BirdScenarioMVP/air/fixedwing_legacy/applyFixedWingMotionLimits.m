function target = applyFixedWingMotionLimits(target, config, dt)
% applyFixedWingMotionLimits - Enforce fixed-wing speed, climb, and world limits.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive} = 1
end

fw = config.fixedWing;
worldSize = config.world.size;
state = string(target.State);
allowExitArea = isfield(fw, 'allowExitArea') && fw.allowExitArea;
allowBoundaryExit = allowExitArea && isfield(target.Payload, 'FinalPhaseStarted') && ...
    target.Payload.FinalPhaseStarted && ...
    (state == "Exit" || (state == "ReturnHome" && target.Payload.FinalMissionCompleted) || ...
    state == "ExitArea");

horizontalSpeed = max(norm(target.Velocity(1:2)), fw.minSpeed);
target.Velocity(3) = limitFixedWingClimbAngle(target.Velocity(3), horizontalSpeed, config);
boundaryRecoveryActive = isfield(target.Payload, 'BoundaryRecoveryActive') && ...
    target.Payload.BoundaryRecoveryActive;
nearBoundary = isfield(target.Payload, 'NearBoundary') && target.Payload.NearBoundary;
if boundaryRecoveryActive || nearBoundary
    target = limitFixedWingBoundaryVelocity(target, config, dt, true);
elseif ~allowBoundaryExit
    target = limitFixedWingBoundaryVelocity(target, config, dt, false);
end

speed = norm(target.Velocity);
if speed > fw.maxSpeed
    target.Velocity = target.Velocity * (fw.maxSpeed / speed);
end

target = enforceFixedWingMinimumSpeed(target, config, dt);

accelNorm = norm(target.Acceleration);
if accelNorm > fw.maxAcceleration
    target.Acceleration = target.Acceleration * (fw.maxAcceleration / accelNorm);
end

if allowBoundaryExit
    target.Position(3) = min(max(target.Position(3), 0), worldSize(3));
else
    pos = target.Position(:);
    pos(1) = min(max(pos(1), 0), worldSize(1));
    pos(2) = min(max(pos(2), 0), worldSize(2));
    target.Position = pos;
    target = projectVelocityAtWorldEdge(target, worldSize, config, dt);
    shouldHardClamp = isfield(fw, 'boundary') && fw.boundary.enabled && ...
        isfield(target.Payload, 'OutsideBoundary') && target.Payload.OutsideBoundary && ...
        isfield(target.Payload, 'TimeOutsideBoundary') && ...
        target.Payload.TimeOutsideBoundary > fw.boundary.maxOutsideTime;
    if shouldHardClamp
        target = clampFixedWingInsideWorld(target, config);
    end
    target.Position(3) = min(max(target.Position(3), 0), worldSize(3));
end

target = enforceFixedWingMinimumSpeed(target, config, dt);

if string(target.State) ~= "Dive"
    target.Position(3) = max(target.Position(3), fw.operatingAltitudeRange(1));
else
    target.Position(3) = max(target.Position(3), ...
        max(0, fw.operatingAltitudeRange(1) - fw.diveAltitudeLossRange(1)));
end
end

function target = clampFixedWingInsideWorld(target, config)
worldSize = config.world.size;
hardMargin = config.fixedWing.boundary.hardMargin;
pos = target.Position(:);
pos(1) = min(max(pos(1), hardMargin), worldSize(1) - hardMargin);
pos(2) = min(max(pos(2), hardMargin), worldSize(2) - hardMargin);
target.Position = pos;
target.Payload.OutsideBoundary = false;
target.Payload.TimeOutsideBoundary = 0;
target.Payload.LastBoundaryEvent = "forcedInside";
end

function target = projectVelocityAtWorldEdge(target, worldSize, config, dt) %#ok<INUSD>
vel = target.Velocity(:);
pos = target.Position(:);
origSpeed = norm(vel(1:2));
if origSpeed < 1e-6
    return;
end

if pos(1) <= 0 && vel(1) < 0
    vel(1) = 0;
elseif pos(1) >= worldSize(1) && vel(1) > 0
    vel(1) = 0;
end
if pos(2) <= 0 && vel(2) < 0
    vel(2) = 0;
elseif pos(2) >= worldSize(2) && vel(2) > 0
    vel(2) = 0;
end
remainSpeed = norm(vel(1:2));
if remainSpeed > 1e-6 && origSpeed > remainSpeed + 1e-3
    vel(1:2) = vel(1:2) / remainSpeed * origSpeed;
    target.Velocity = vel;
elseif remainSpeed > 1e-6
    target.Velocity = vel;
end
end

function target = enforceFixedWingMinimumSpeed(target, config, dt)
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive} = 1
end
fw = config.fixedWing;
speed = norm(target.Velocity);
if speed >= fw.minSpeed - 1e-6
    return;
end
heading = target.Payload.CurrentHeading;
if norm(target.Velocity(1:2)) > 1e-6
    heading = atan2(target.Velocity(2), target.Velocity(1));
end
maxRaise = fw.maxAcceleration * dt;
targetSpeed = min(speed + maxRaise, fw.minSpeed);
vz = limitFixedWingClimbAngle(target.Velocity(3), targetSpeed, config);
horizontalSpeed = sqrt(max(targetSpeed ^ 2 - vz ^ 2, 0));
target.Velocity = [cos(heading) * horizontalSpeed; sin(heading) * horizontalSpeed; vz];
end
