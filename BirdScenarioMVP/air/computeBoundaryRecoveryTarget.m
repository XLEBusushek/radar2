function recoveryTarget = computeBoundaryRecoveryTarget(target, config)
% computeBoundaryRecoveryTarget - Pick a stable inward recovery point near boundary.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

worldSize = config.world.size;
boundaryCfg = config.fixedWing.boundary;
navMargin = getWaypointBoundaryMargin(config.fixedWing);
pos = target.Position(:);
heading = target.Payload.CurrentHeading;
if isnan(heading)
    heading = atan2(target.Velocity(2), target.Velocity(1));
end

distLeft = pos(1);
distRight = worldSize(1) - pos(1);
distBottom = pos(2);
distTop = worldSize(2) - pos(2);
[minDist, edgeIdx] = min([distLeft, distRight, distBottom, distTop]);

inwardRange = boundaryCfg.recoveryInwardDistanceRange;
inwardDistance = inwardRange(1) + rand() * (inwardRange(2) - inwardRange(1));
inwardDistance = max(inwardDistance, minDist + navMargin * 0.5);

switch edgeIdx
    case 1
        inwardNormal = [1; 0];
    case 2
        inwardNormal = [-1; 0];
    case 3
        inwardNormal = [0; 1];
    otherwise
        inwardNormal = [0; -1];
end

forward = target.Velocity(1:2);
if norm(forward) > config.fixedWing.minSpeed * 0.5
    forward = forward / norm(forward);
else
    forward = [cos(heading); sin(heading)];
end
if dot(forward, inwardNormal) < 0
    forward = forward * 0.35 + inwardNormal * 0.65;
else
    forward = forward * 0.7 + inwardNormal * 0.3;
end
blendDir = forward;
if norm(blendDir) < 1e-6
    blendDir = inwardNormal;
else
    blendDir = blendDir / norm(blendDir);
end

xy = pos(1:2) + blendDir * inwardDistance;
xy(1) = min(max(xy(1), navMargin), worldSize(1) - navMargin);
xy(2) = min(max(xy(2), navMargin), worldSize(2) - navMargin);

if minDist < 1e-6
    xy = xy + inwardNormal * max(inwardDistance, navMargin);
    xy(1) = min(max(xy(1), navMargin), worldSize(1) - navMargin);
    xy(2) = min(max(xy(2), navMargin), worldSize(2) - navMargin);
end

altitude = target.Payload.FlightLevel;
if isnan(altitude) || isempty(altitude)
    altitude = target.Position(3);
end
recoveryTarget = [xy; altitude];
end

function margin = getWaypointBoundaryMargin(fw)
if isfield(fw, 'navigation') && isfield(fw.navigation, 'minWaypointBoundaryMargin')
    margin = fw.navigation.minWaypointBoundaryMargin;
elseif isfield(fw, 'boundary') && isfield(fw.boundary, 'margin')
    margin = fw.boundary.margin;
else
    margin = 200;
end
end
