function mission = generateQuadcopterMission(homePosition, config)
% generateQuadcopterMission - Сгенерировать маршрут по точкам для квадрокоптера.
arguments
    homePosition (3, 1) double
    config (1, 1) struct
end

worldSize = config.world.size;
qc = config.quadcopter;
numWaypoints = randi(qc.waypointCountRange);
nav = qc.navigation;

waypoints = zeros(numWaypoints, 3);
fallbackCount = 0;
previousPoint = homePosition(:).';
for i = 1:numWaypoints
    [candidate, usedFallback] = generateWaypointCandidate(previousPoint, qc, nav, worldSize);
    waypoint = enforceQuadcopterWaypointDistance(previousPoint(:), candidate(:), config);
    waypoints(i, :) = waypoint(:).';
    fallbackCount = fallbackCount + usedFallback;
    previousPoint = waypoints(i, :);
end

mission.HomePosition = homePosition(:);
mission.Waypoints = waypoints;
mission.CurrentWaypointIndex = 1;
if numWaypoints > 0
    mission.CurrentWaypoint = waypoints(1, :).';
else
    mission.CurrentWaypoint = homePosition(:);
end
mission.WaypointArrivalRadius = qc.waypointArrivalRadius;
mission.NavigationFallbackCount = fallbackCount;
end

function [waypoint, usedFallback] = generateWaypointCandidate(previousPoint, qc, nav, worldSize)
maxAttempts = 30;
usedFallback = false;
altRange = qc.operatingAltitudeRange;

for attempt = 1:maxAttempts
    radius = selectWaypointRadius(nav);
    angle = 2 * pi * rand();
    xy = previousPoint(1:2) + radius * [cos(angle), sin(angle)];
    altitude = selectWaypointAltitude(previousPoint(3), altRange, nav, attempt);
    waypoint = [xy, altitude];
    waypoint = enforceWorldBounds(waypoint(:), worldSize).';

    dXY = norm(waypoint(1:2) - previousPoint(1:2));
    if dXY >= nav.minWaypointDistance && dXY <= nav.maxWaypointDistance
        return;
    end
end

usedFallback = true;
radius = mean([nav.minWaypointDistance, nav.maxWaypointDistance]);
angle = 2 * pi * rand();
xy = previousPoint(1:2) + radius * [cos(angle), sin(angle)];
altitude = selectWaypointAltitude(previousPoint(3), altRange, nav, maxAttempts);
waypoint = enforceWorldBounds([xy, altitude].', worldSize).';
end

function radius = selectWaypointRadius(nav)
totalProb = nav.localWaypointProbability + nav.globalWaypointProbability;
if totalProb <= 0 || rand() <= nav.localWaypointProbability / totalProb
    lo = max(nav.minWaypointDistance, 200);
    hi = min(nav.maxWaypointDistance, 400);
else
    lo = max(nav.minWaypointDistance, 400);
    hi = nav.maxWaypointDistance;
end

if hi < lo
    lo = nav.minWaypointDistance;
    hi = nav.maxWaypointDistance;
end
radius = lo + rand() * max(0, hi - lo);
end

function altitude = selectWaypointAltitude(previousAltitude, altRange, nav, attempt)
altitude = altRange(1) + rand() * (altRange(2) - altRange(1));
if mod(attempt, 2) == 0 || abs(altitude - previousAltitude) >= nav.minAltitudeChange
    return;
end

if previousAltitude + nav.minAltitudeChange <= altRange(2) && ...
        previousAltitude - nav.minAltitudeChange >= altRange(1)
    if rand() < 0.5
        lo = previousAltitude + nav.minAltitudeChange;
        hi = altRange(2);
    else
        lo = altRange(1);
        hi = previousAltitude - nav.minAltitudeChange;
    end
elseif previousAltitude + nav.minAltitudeChange <= altRange(2)
    lo = previousAltitude + nav.minAltitudeChange;
    hi = altRange(2);
elseif previousAltitude - nav.minAltitudeChange >= altRange(1)
    lo = altRange(1);
    hi = previousAltitude - nav.minAltitudeChange;
else
    return;
end

altitude = lo + rand() * max(0, hi - lo);
end
