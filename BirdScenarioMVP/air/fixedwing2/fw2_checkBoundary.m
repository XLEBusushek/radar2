function target = fw2_checkBoundary(target, config, dt)
% fw2_checkBoundary - Классификация зон, следование по границе, триггер восстановления.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

fw2 = config.fixedWing2;
zones = fw2_getZoneBounds(config);
worldSize = config.world.size;
pos = target.Position(:);
[distanceToBoundary, ~] = computeDistanceToWorldBoundary(pos, worldSize);

target.Payload.SafeZone = zones.SafeZone;
target.Payload.DistanceToBoundary = distanceToBoundary;
target.Payload.InSafeZone = distanceToBoundary >= zones.SafeMargin;
target.Payload.InCriticalZone = distanceToBoundary < zones.CriticalMargin;
target.Payload.InWarningZone = ~target.Payload.InSafeZone && ~target.Payload.InCriticalZone;

if string(target.State) == "BoundaryRecovery"
    heading = target.Payload.CurrentHeading;
    [~, borderSide] = fw2_nearestBorderSide(pos(1:2), worldSize);
    parallel = fw2_isHeadingParallel(heading, borderSide, fw2.boundary.borderParallelAngleDeg);
    if target.Payload.InWarningZone && parallel
        target.Payload.BorderFollowingTime = min(target.Payload.BorderFollowingTime + dt, ...
            fw2.boundary.maxBorderParallelTime + dt);
    else
        target.Payload.BorderFollowingTime = max(0, target.Payload.BorderFollowingTime - dt);
    end
    target.Payload.BorderFollowing = target.Payload.BorderFollowingTime >= fw2.boundary.maxBorderParallelTime;
    return;
end

heading = target.Payload.CurrentHeading;
[~, borderSide] = fw2_nearestBorderSide(pos(1:2), worldSize);
parallel = fw2_isHeadingParallel(heading, borderSide, fw2.boundary.borderParallelAngleDeg);

if target.Payload.InWarningZone && parallel
    target.Payload.BorderFollowingTime = min(target.Payload.BorderFollowingTime + dt, ...
        fw2.boundary.maxBorderParallelTime + dt);
else
    target.Payload.BorderFollowingTime = 0;
end
target.Payload.BorderFollowing = target.Payload.BorderFollowingTime >= fw2.boundary.maxBorderParallelTime;

if target.Payload.BorderFollowing && string(target.State) ~= "BoundaryRecovery"
    target.State = "BoundaryRecovery";
    if isempty(target.Payload.RecoveryPoint)
        target.Payload.RecoveryPoint = fw2_computeSafeRecoveryPoint(target, config);
    end
    target.Payload.LastFW2Event = "borderFollowing";
    target.TimeInState = 0;
elseif target.Payload.InCriticalZone && string(target.State) ~= "BoundaryRecovery"
    if isempty(target.Payload.RecoveryPoint)
        target.Payload.RecoveryPoint = fw2_computeSafeRecoveryPoint(target, config);
    end
    target.State = "BoundaryRecovery";
    target.Payload.LastFW2Event = "criticalZone";
    target.TimeInState = 0;
elseif target.Payload.InWarningZone && string(target.State) == "Cruise"
    if isempty(target.Payload.RecoveryPoint)
        target.Payload.RecoveryPoint = fw2_computeSafeRecoveryPoint(target, config);
    end
    target.State = "BoundaryRecovery";
    target.Payload.LastFW2Event = "warningZone";
    target.TimeInState = 0;
end
end

function parallel = fw2_isHeadingParallel(heading, side, angleDeg)
flightDir = [cos(heading); sin(heading)];
switch string(side)
    case {"left", "right"}
        borderDir = [0; 1];
    otherwise
        borderDir = [1; 0];
end
angle = abs(acos(min(1, abs(dot(flightDir, borderDir)))));
threshold = deg2rad(angleDeg);
parallel = angle <= threshold || abs(pi - angle) <= threshold;
end

function [side, dist] = fw2_nearestBorderSide(pos, worldSize)
distances = [pos(1), worldSize(1) - pos(1), pos(2), worldSize(2) - pos(2)];
[dist, idx] = min(distances);
sides = ["left", "right", "bottom", "top"];
side = sides(idx);
end
