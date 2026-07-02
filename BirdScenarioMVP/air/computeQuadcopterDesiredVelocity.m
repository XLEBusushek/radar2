function target = computeQuadcopterDesiredVelocity(target, config)
% computeQuadcopterDesiredVelocity - State-based velocity command for quadcopter.
qc = config.quadcopter;
state = string(target.State);

switch state
    case "Idle"
        target.Payload.DesiredVelocity = zeros(3, 1);
        target.Payload.DesiredSpeed = 0;
    case "Takeoff"
        altitudeError = target.Payload.TakeoffTargetAltitude - target.Position(3);
        vz = min(max(altitudeError, 0), qc.maxVerticalSpeed * 0.8);
        target.Payload.DesiredVelocity = [0; 0; vz];
        target.Payload.DesiredSpeed = vz;
    case "Transit"
        if isempty(target.Payload.DesiredSpeed) || target.Payload.DesiredSpeed == 0
            target.Payload.DesiredSpeed = qc.transitSpeedRange(1) + ...
                rand() * (qc.transitSpeedRange(2) - qc.transitSpeedRange(1));
        end
        wp = target.Payload.CurrentWaypoint(:);
        target.Payload.DesiredAltitude = wp(3);
        target = setVelocityTowardXYAndAltitude(target, wp, target.Payload.DesiredSpeed, qc, config);
    case "Hover"
        anchor = target.Payload.HoverAnchor(:);
        delta = anchor - target.Position;
        if norm(delta) > 2
            target.Payload.DesiredAltitude = anchor(3);
            target = setVelocityTowardXYAndAltitude(target, anchor, 1.5, qc, config);
        else
            target.Payload.DesiredVelocity = -0.8 * target.Velocity;
            target.Payload.DesiredVelocity(3) = clamp(target.Payload.DesiredAltitude - target.Position(3), ...
                -qc.maxVerticalSpeed, qc.maxVerticalSpeed);
            target.Payload.DesiredSpeed = norm(target.Payload.DesiredVelocity);
        end
    case "Scan"
        target = computeScanVelocity(target, qc, config);
    case "Return"
        if target.Payload.DesiredSpeed == 0
            target.Payload.DesiredSpeed = mean(qc.transitSpeedRange);
        end
        home = target.Payload.HomePosition(:);
        distXY = norm(home(1:2) - target.Position(1:2));
        safeAltitude = max(home(3) + 40, qc.operatingAltitudeRange(1));
        if distXY > max(50, target.Payload.WaypointArrivalRadius * 2)
            target.Payload.DesiredAltitude = max(target.Position(3), safeAltitude);
        else
            target.Payload.DesiredAltitude = home(3);
        end
        returnTarget = [home(1); home(2); target.Payload.DesiredAltitude];
        target = setVelocityTowardXYAndAltitude(target, returnTarget, target.Payload.DesiredSpeed, qc, config);
    case "Landing"
        if target.Payload.DesiredSpeed == 0
            target.Payload.DesiredSpeed = mean(qc.landingSpeedRange);
        end
        home = target.Payload.HomePosition(:);
        landingTarget = home;
        landingTarget(3) = 0;
        target.Payload.DesiredAltitude = 0;
        target = setVelocityTowardXYAndAltitude(target, landingTarget, target.Payload.DesiredSpeed, qc, config);
    otherwise
        target.Payload.DesiredVelocity = zeros(3, 1);
        target.Payload.DesiredSpeed = 0;
end
end

function target = setVelocityTowardXYAndAltitude(target, goal, speed, qc, config)
goal = goal(:);
deltaXY = goal(1:2) - target.Position(1:2);
distXY = norm(deltaXY);

if distXY < 1e-6
    desiredXY = [0; 0];
else
    targetDirXY = deltaXY / distXY;
    currentXY = target.Velocity(1:2);
    if norm(currentXY) > 1e-6 && ...
            ~(isfield(target.Payload, 'ForceDirectToWaypoint') && target.Payload.ForceDirectToWaypoint)
        currentDirXY = currentXY / norm(currentXY);
        targetDirXY = 0.85 * targetDirXY + 0.15 * currentDirXY;
        targetDirXY = targetDirXY / norm(targetDirXY);
    end
    if isfield(target.Payload, 'ForceDirectToWaypoint') && target.Payload.ForceDirectToWaypoint
        blend = config.quadcopter.navigation.forceDirectBlend;
        targetDirXY = blend * targetDirXY;
        targetDirXY = targetDirXY / max(norm(targetDirXY), 1e-6);
    end
    desiredXY = targetDirXY * speed;
end

if ~isfield(target.Payload, 'DesiredAltitude') || isempty(target.Payload.DesiredAltitude)
    target.Payload.DesiredAltitude = goal(3);
end
altitudeError = target.Payload.DesiredAltitude - target.Position(3);
vz = clamp(altitudeError, -qc.maxVerticalSpeed, qc.maxVerticalSpeed);

target.Payload.DesiredVelocity = [desiredXY; vz];
target.Payload.DesiredSpeed = speed;
end

function target = computeScanVelocity(target, qc, config)
center = target.Payload.ScanCenter(:);
radius = target.Payload.ScanRadius;
angle = target.Payload.ScanAngle;
dir = target.Payload.ScanDirection;

omega = 0.4 * dir;
target.Payload.ScanAngle = angle + omega * 0.1;

x = center(1) + radius * cos(target.Payload.ScanAngle);
y = center(2) + radius * sin(target.Payload.ScanAngle);
z = center(3) + 2 * sin(target.Payload.ScanAngle * 2);

scanPoint = [x; y; z];
target.Payload.DesiredAltitude = center(3);
speed = target.Payload.DesiredSpeed;
if speed == 0
    speed = mean(qc.scanSpeedRange);
end
target = setVelocityTowardXYAndAltitude(target, scanPoint, speed, qc, config);
end

function value = clamp(value, lowerBound, upperBound)
value = min(max(value, lowerBound), upperBound);
end
