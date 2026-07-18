function mission = fw2_generateMission(startPoint, initialHeading, config)
% fw2_generateMission - Сгенерировать точки маршрута внутри safe zone.
arguments
    startPoint (3, 1) double
    initialHeading (1, 1) double
    config (1, 1) struct
end

fw2 = config.fixedWing2;
maxTurn = fw2.route.maxHeadingChangeDeg;

for attempt = 1:50
    mission = fw2_generateMissionOnce(startPoint, initialHeading, config);
    if fw2_validateMission(mission, config, maxTurn)
        return;
    end
end
mission = fw2_generateMissionDeterministic(startPoint, initialHeading, config);
end

function mission = fw2_generateMissionDeterministic(startPoint, initialHeading, config)
fw2 = config.fixedWing2;
safe = fw2_getZoneBounds(config).SafeZone;
numPoints = fw2.route.waypointCountRange(1);
routePoints = zeros(numPoints, 3);
center = [(safe(1) + safe(2)) / 2, (safe(3) + safe(4)) / 2];
radius = min(safe(2) - safe(1), safe(4) - safe(3)) / 2 - 100;
nominalAltitude = fw2_nearestFlightLevel(startPoint(3), config);
minLeg = fw2.route.minLegLength;

for i = 1:numPoints
    angle = initialHeading + deg2rad((i - 1) * (fw2.route.minHeadingChangeDeg + 12));
    xy = center + radius * [cos(angle), sin(angle)];
    xy(1) = min(max(xy(1), safe(1)), safe(2));
    xy(2) = min(max(xy(2), safe(3)), safe(4));
    routePoints(i, :) = [xy, nominalAltitude];
end

for i = 2:numPoints
    legLen = norm(routePoints(i, 1:2) - routePoints(i - 1, 1:2));
    if legLen < minLeg - 1e-6
        angle = atan2(routePoints(i, 2) - center(2), routePoints(i, 1) - center(1)) + pi / 3;
        xy = routePoints(i - 1, 1:2) + minLeg * [cos(angle), sin(angle)];
        xy(1) = min(max(xy(1), safe(1)), safe(2));
        xy(2) = min(max(xy(2), safe(3)), safe(4));
        routePoints(i, :) = [xy, nominalAltitude];
    end
end

mission.RoutePoints = routePoints;
mission.HomePoint = startPoint(:);
mission.MissionID = randi(1e6);
mission.RouteIndex = 1;
mission.RouteComplete = false;
end

function mission = fw2_generateMissionOnce(startPoint, initialHeading, config)
fw2 = config.fixedWing2;
numPoints = randi(fw2.route.waypointCountRange);
routePoints = zeros(numPoints, 3);
previousPoint = startPoint(:);
previousHeading = initialHeading;
nominalAltitude = fw2_nearestFlightLevel(startPoint(3), config);

for i = 1:numPoints
    [waypoint, ~] = fw2_generateSafeWaypoint(previousPoint, previousHeading, nominalAltitude, config);
    routePoints(i, :) = waypoint;
    delta = waypoint(1:2) - previousPoint(1:2).';
    if norm(delta) > 1e-6
        previousHeading = atan2(delta(2), delta(1));
    end
    previousPoint = waypoint(:);
end

mission.RoutePoints = routePoints;
mission.HomePoint = startPoint(:);
mission.MissionID = randi(1e6);
mission.RouteIndex = 1;
mission.RouteComplete = false;
end

function valid = fw2_validateMission(mission, config, maxTurnDeg)
zones = fw2_getZoneBounds(config);
safe = zones.SafeZone;
points = mission.RoutePoints;
for i = 1:size(points, 1)
    if ~fw2_pointInSafe(points(i, 1:2), safe)
        valid = false;
        return;
    end
end
if size(points, 1) < 2
    valid = true;
    return;
end
legs = diff(points(:, 1:2), 1, 1);
lengths = vecnorm(legs, 2, 2);
if any(lengths < config.fixedWing2.route.minLegLength - 1e-6) || ...
        any(lengths > config.fixedWing2.route.maxLegLength + 1e-6)
    valid = false;
    return;
end
if size(points, 1) >= 3
    headings = atan2(diff(points(:, 2)), diff(points(:, 1)));
    changes = abs(arrayfun(@fw2_wrapAngle, diff(headings))) * 180 / pi;
    valid = all(changes <= maxTurnDeg + 1e-6);
else
    valid = true;
end
end

function inside = fw2_pointInSafe(xy, safe)
inside = xy(1) >= safe(1) && xy(1) <= safe(2) && xy(2) >= safe(3) && xy(2) <= safe(4);
end

function level = fw2_nearestFlightLevel(altitude, config)
levels = config.fixedWing2.altitude.range(1):config.fixedWing2.altitude.levelSpacing: ...
    config.fixedWing2.altitude.range(2);
if isempty(levels)
    level = altitude;
    return;
end
[~, idx] = min(abs(levels - altitude));
level = levels(idx);
end
