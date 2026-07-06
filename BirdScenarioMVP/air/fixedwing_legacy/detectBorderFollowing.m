function target = detectBorderFollowing(target, config, dt)
% detectBorderFollowing - Detect prolonged flight parallel to a map border.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

zoneCfg = config.fixedWing.zones;
zoneInfo = classifyFixedWingZone(target.Position, config);

target.Payload.BorderSide = zoneInfo.BorderSide;
target.Payload.DistanceToBoundary = zoneInfo.DistanceToBoundary;

if string(target.State) == "BorderAvoidance"
    target.Payload.BorderFollowing = true;
    target.Payload.BorderFollowingTime = min(target.Payload.BorderFollowingTime, zoneCfg.borderFollowingMaxTime);
    return;
end

parallelThreshold = deg2rad(zoneCfg.borderParallelAngleDeg);
borderDistance = zoneCfg.borderFollowingDistance;

heading = target.Payload.CurrentHeading;
if isnan(heading)
    heading = atan2(target.Velocity(2), target.Velocity(1));
end

parallel = isHeadingParallelToBorder(heading, zoneInfo.BorderSide, parallelThreshold);
nearBorder = zoneInfo.DistanceToBoundary < borderDistance;

if nearBorder && parallel
    target.Payload.BorderFollowingTime = min( ...
        target.Payload.BorderFollowingTime + dt, zoneCfg.borderFollowingMaxTime);
else
    target.Payload.BorderFollowingTime = 0;
end

target.Payload.BorderFollowing = target.Payload.BorderFollowingTime >= zoneCfg.borderFollowingMaxTime;
end

function parallel = isHeadingParallelToBorder(heading, side, threshold)
flightDir = [cos(heading); sin(heading)];
switch string(side)
    case "left"
        borderDir = [0; 1];
    case "right"
        borderDir = [0; 1];
    case "bottom"
        borderDir = [1; 0];
    otherwise
        borderDir = [1; 0];
end
angle = abs(acos(min(1, abs(dot(flightDir, borderDir)))));
parallel = angle <= threshold || abs(pi - angle) <= threshold;
end
