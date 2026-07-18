function [point, accepted] = fw2_generateSafeWaypoint(previousPoint, previousHeading, nominalAltitude, config)
% fw2_generateSafeWaypoint - Сгенерировать одну точку маршрута внутри safe zone.
arguments
    previousPoint (3, 1) double
    previousHeading (1, 1) double
    nominalAltitude (1, 1) double
    config (1, 1) struct
end

fw2 = config.fixedWing2;
zones = fw2_getZoneBounds(config);
safe = zones.SafeZone;
route = fw2.route;
minLeg = route.minLegLength;
maxLeg = route.maxLegLength;
minDelta = deg2rad(route.minHeadingChangeDeg);
maxDelta = deg2rad(route.maxHeadingChangeDeg);
warnM = zones.WarningMargin;

accepted = false;
point = previousPoint(:).';

for attempt = 1:80
    distance = minLeg + rand() * (maxLeg - minLeg);
    deltaDeg = route.minHeadingChangeDeg + rand() * (route.maxHeadingChangeDeg - route.minHeadingChangeDeg);
    if rand() < 0.5
        deltaDeg = -deltaDeg;
    end
    heading = previousHeading + deg2rad(deltaDeg);
    xy = previousPoint(1:2).' + distance * [cos(heading), sin(heading)];
    if ~fw2_pointInsideSafe(xy, safe)
        continue;
    end
    legVec = xy - previousPoint(1:2).';
    if fw2_legParallelToBorder(previousPoint(1:2), legVec, warnM, config)
        continue;
    end
    alt = nominalAltitude + (rand() * 2 - 1) * fw2.altitude.tolerance;
    alt = min(max(alt, fw2.altitude.range(1)), fw2.altitude.range(2));
    if norm(xy - previousPoint(1:2).') < minLeg - 1e-6
        continue;
    end
    point = [xy, alt];
    accepted = true;
    return;
end

point = fw2_fallbackWaypoint(previousPoint, previousHeading, nominalAltitude, config, safe, minLeg, maxLeg, maxDelta);
accepted = true;
end

function inside = fw2_pointInsideSafe(xy, safe)
inside = xy(1) >= safe(1) && xy(1) <= safe(2) && xy(2) >= safe(3) && xy(2) <= safe(4);
end

function parallel = fw2_legParallelToBorder(startXY, legVec, warnMargin, config)
worldSize = config.world.size;
endXY = startXY(:) + legVec(:);
distStart = min([startXY(1), worldSize(1) - startXY(1), startXY(2), worldSize(2) - startXY(2)]);
distEnd = min([endXY(1), worldSize(1) - endXY(1), endXY(2), worldSize(2) - endXY(2)]);
if distStart >= warnMargin && distEnd >= warnMargin
    parallel = false;
    return;
end
legLen = norm(legVec);
if legLen < 1e-6
    parallel = false;
    return;
end
legDir = legVec / legLen;
heading = atan2(legDir(2), legDir(1));
threshold = deg2rad(config.fixedWing2.boundary.borderParallelAngleDeg);
[~, borderSide] = fw2_nearestBorderSide(startXY, worldSize);
parallel = fw2_isHeadingParallelToBorder(heading, borderSide, threshold);
end

function [side, dist] = fw2_nearestBorderSide(pos, worldSize)
distances = [pos(1), worldSize(1) - pos(1), pos(2), worldSize(2) - pos(2)];
[dist, idx] = min(distances);
sides = ["left", "right", "bottom", "top"];
side = sides(idx);
end

function parallel = fw2_isHeadingParallelToBorder(heading, side, threshold)
flightDir = [cos(heading); sin(heading)];
switch string(side)
    case {"left", "right"}
        borderDir = [0; 1];
    otherwise
        borderDir = [1; 0];
end
angle = abs(acos(min(1, abs(dot(flightDir, borderDir)))));
parallel = angle <= threshold || abs(pi - angle) <= threshold;
end

function waypoint = fw2_fallbackWaypoint(previousPoint, previousHeading, nominalAltitude, config, safe, minLeg, maxLeg, maxDelta)
center = [(safe(1) + safe(2)) / 2, (safe(3) + safe(4)) / 2];
direction = center - previousPoint(1:2).';
if norm(direction) < 1e-6
    direction = [cos(previousHeading), sin(previousHeading)];
else
    ch = atan2(direction(2), direction(1));
    lh = previousHeading + min(max(fw2_wrapAngle(ch - previousHeading), -maxDelta), maxDelta);
    direction = [cos(lh), sin(lh)];
end
distance = minLeg + rand() * (maxLeg - minLeg);
xy = previousPoint(1:2).' + distance * direction / max(norm(direction), 1e-6);
if norm(xy - previousPoint(1:2).') < minLeg - 1
    xy = previousPoint(1:2).' + minLeg * direction / max(norm(direction), 1e-6);
end
xy(1) = min(max(xy(1), safe(1)), safe(2));
xy(2) = min(max(xy(2), safe(3)), safe(4));
if norm(xy - previousPoint(1:2).') < minLeg - 1
    xy = previousPoint(1:2).' + minLeg * [cos(previousHeading), sin(previousHeading)];
    xy(1) = min(max(xy(1), safe(1)), safe(2));
    xy(2) = min(max(xy(2), safe(3)), safe(4));
end
alt = min(max(nominalAltitude, config.fixedWing2.altitude.range(1)), config.fixedWing2.altitude.range(2));
waypoint = [xy, alt];
end
