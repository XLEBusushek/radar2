function mission = generateSafeMission(homePosition, initialHeading, config)
% generateSafeMission - Сгенерировать длинные прямые маршруты полностью внутри Safe Zone.
arguments
    homePosition (3, 1) double
    initialHeading (1, 1) double
    config (1, 1) struct
end

fw = config.fixedWing;
maxHeadingChangeDeg = getNavValue(fw, 'maxHeadingChangeDeg', 70);
maxHeadingChangeDeg = min(maxHeadingChangeDeg, getNavValue(fw, 'maxRouteTurnDeg', 70));

for attempt = 1:25
    mission = generateSafeMissionOnce(homePosition, initialHeading, config);
    if validateMissionInsideSafeZone(mission, config) && ...
            validateMissionRoute(homePosition(:).', mission.Waypoints, maxHeadingChangeDeg)
        return;
    end
end
end

function mission = generateSafeMissionOnce(homePosition, initialHeading, config)
fw = config.fixedWing;
worldSize = config.world.size;
zones = getFixedWingZoneBounds(config);
safe = zones.SafeZone;

numWaypoints = randi(fw.waypointCountRange);
waypoints = zeros(numWaypoints, 3);

previousPoint = homePosition(:).';
previousHeading = initialHeading;
nominalAltitude = nearestFlightLevel(homePosition(3), fw);

for i = 1:numWaypoints
    waypoint = generateSafeCandidate(previousPoint, previousHeading, nominalAltitude, fw, safe, i < numWaypoints);
    waypoints(i, :) = waypoint;
    delta = waypoint(1:2) - previousPoint(1:2);
    if norm(delta) > 1e-6
        previousHeading = atan2(delta(2), delta(1));
    end
    previousPoint = waypoint;
end

allowExitArea = isfield(fw, 'allowExitArea') && fw.allowExitArea;
if allowExitArea
    if size(waypoints, 1) > 1
        previousExitPoint = waypoints(end - 1, :).';
    else
        previousExitPoint = homePosition(:);
    end
    exitPoint = selectExitPoint(waypoints(end, :).', previousExitPoint, worldSize, fw);
    exitPoint = validateExitPoint(exitPoint, waypoints(end, :).', worldSize, fw);
else
    exitPoint = waypoints(end, :).';
end

mission.HomePosition = homePosition(:);
mission.ExitPoint = exitPoint(:);
mission.FinalStrategy = selectFinalStrategy(fw);
mission.Waypoints = waypoints;
mission.CurrentWaypointIndex = 1;
mission.CurrentWaypoint = waypoints(1, :).';
if isfield(fw, 'navigation') && isfield(fw.navigation, 'arrivalRadius')
    mission.WaypointArrivalRadius = fw.navigation.arrivalRadius;
else
    mission.WaypointArrivalRadius = fw.waypointArrivalRadius;
end
end

function waypoint = generateSafeCandidate(previousPoint, previousHeading, nominalAltitude, fw, safe, needsContinuation)
minLeg = getNavValue(fw, 'minLegLength', getNavValue(fw, 'minStraightLegLength', 600));
maxLeg = getNavValue(fw, 'maxLegLength', getNavValue(fw, 'maxStraightLegLength', 1400));
minHeadingChangeDeg = getNavValue(fw, 'minHeadingChangeDeg', 15);
maxHeadingChangeDeg = min(getNavValue(fw, 'maxHeadingChangeDeg', 70), ...
    getNavValue(fw, 'maxRouteTurnDeg', 70));

for attempt = 1:80
    distance = sampleRange([minLeg, maxLeg]);
    deltaHeadingDeg = sampleSignedRange([minHeadingChangeDeg, maxHeadingChangeDeg]);
    heading = previousHeading + deg2rad(deltaHeadingDeg);
    xy = previousPoint(1:2) + distance * [cos(heading), sin(heading)];
    altitude = nominalAltitude + (rand() * 2 - 1) * fw.flightLevel.altitudeTolerance;
    altitude = min(max(altitude, fw.operatingAltitudeRange(1)), fw.operatingAltitudeRange(2));
    if ~isInsideSafeBounds(xy, safe)
        continue;
    end
    candidate = [xy, altitude];
    if isValidLeg(previousPoint, candidate, previousHeading, minLeg, maxLeg, maxHeadingChangeDeg) && ...
            (~needsContinuation || hasFeasibleContinuation(candidate, heading, fw, safe, maxHeadingChangeDeg))
        waypoint = candidate;
        return;
    end
end

headingDeltas = linspace(deg2rad(minHeadingChangeDeg), deg2rad(maxHeadingChangeDeg), 13);
headingDeltas = [headingDeltas, -headingDeltas];
distances = linspace(minLeg, maxLeg, 8);
for r = 1:numel(distances)
    for h = 1:numel(headingDeltas)
        heading = previousHeading + headingDeltas(h);
        xy = previousPoint(1:2) + distances(r) * [cos(heading), sin(heading)];
        if ~isInsideSafeBounds(xy, safe)
            continue;
        end
        altitude = min(max(nominalAltitude, fw.operatingAltitudeRange(1)), fw.operatingAltitudeRange(2));
        candidate = [xy, altitude];
        if isValidLeg(previousPoint, candidate, previousHeading, minLeg, maxLeg, maxHeadingChangeDeg) && ...
                (~needsContinuation || hasFeasibleContinuation(candidate, heading, fw, safe, maxHeadingChangeDeg))
            waypoint = candidate;
            return;
        end
    end
end

waypoint = fallbackSafeWaypoint(previousPoint, previousHeading, nominalAltitude, fw, safe, minLeg, maxLeg, maxHeadingChangeDeg);
end

function waypoint = fallbackSafeWaypoint(previousPoint, previousHeading, nominalAltitude, fw, safe, minLeg, maxLeg, maxHeadingChangeDeg)
center = [(safe(1) + safe(2)) / 2, (safe(3) + safe(4)) / 2];
direction = center - previousPoint(1:2);
if norm(direction) < 1e-6
    direction = [cos(previousHeading), sin(previousHeading)];
else
    centerHeading = atan2(direction(2), direction(1));
    limitedHeading = previousHeading + min(max(wrapToPiLocal(centerHeading - previousHeading), ...
        -deg2rad(maxHeadingChangeDeg)), deg2rad(maxHeadingChangeDeg));
    direction = [cos(limitedHeading), sin(limitedHeading)];
end
distance = min(max(minLeg, norm(center - previousPoint(1:2))), maxLeg);
xy = previousPoint(1:2) + distance * direction;
xy(1) = min(max(xy(1), safe(1)), safe(2));
xy(2) = min(max(xy(2), safe(3)), safe(4));
altitude = min(max(nominalAltitude, fw.operatingAltitudeRange(1)), fw.operatingAltitudeRange(2));
waypoint = [xy, altitude];
end

function inside = isInsideSafeBounds(xy, safe)
inside = xy(1) >= safe(1) && xy(1) <= safe(2) && xy(2) >= safe(3) && xy(2) <= safe(4);
end

function valid = isValidLeg(previousPoint, candidate, previousHeading, minLeg, maxLeg, maxHeadingChangeDeg)
delta = candidate(1:2) - previousPoint(1:2);
distance = norm(delta);
if distance < minLeg - 1e-6 || distance > maxLeg + 1e-6
    valid = false;
    return;
end
heading = atan2(delta(2), delta(1));
turnDeg = abs(wrapToPiLocal(heading - previousHeading)) * 180 / pi;
valid = turnDeg <= maxHeadingChangeDeg + 1e-6;
end

function feasible = hasFeasibleContinuation(point, heading, fw, safe, maxHeadingChangeDeg)
feasible = false;
minLeg = getNavValue(fw, 'minLegLength', getNavValue(fw, 'minStraightLegLength', 600));
maxLeg = getNavValue(fw, 'maxLegLength', getNavValue(fw, 'maxStraightLegLength', 1400));
distances = linspace(minLeg, maxLeg, 6);
headingDeltas = linspace(-deg2rad(maxHeadingChangeDeg), deg2rad(maxHeadingChangeDeg), 13);
for r = 1:numel(distances)
    for h = 1:numel(headingDeltas)
        nextHeading = heading + headingDeltas(h);
        xy = point(1:2) + distances(r) * [cos(nextHeading), sin(nextHeading)];
        if isInsideSafeBounds(xy, safe)
            feasible = true;
            return;
        end
    end
end
end

function valid = validateMissionRoute(homePoint, waypoints, maxHeadingChangeDeg)
points = [homePoint(:).'; waypoints];
if size(points, 1) < 3
    valid = true;
    return;
end
headings = atan2(diff(points(:, 2)), diff(points(:, 1)));
headingChanges = abs(arrayfun(@wrapToPiLocal, diff(headings))) * 180 / pi;
valid = all(headingChanges <= maxHeadingChangeDeg + 1e-6);
end

function strategy = selectFinalStrategy(fw)
allowExitArea = isfield(fw, 'allowExitArea') && fw.allowExitArea;
if allowExitArea
    weights = [0.6, 0.2, 0.2];
    labels = ["Exit", "ReturnHome", "LoiterEnd"];
    if isfield(fw, 'finalPhase') && isfield(fw.finalPhase, 'strategyWeights')
        weights = [fw.finalPhase.strategyWeights.Exit, ...
            fw.finalPhase.strategyWeights.ReturnHome, ...
            fw.finalPhase.strategyWeights.LoiterEnd];
    end
else
    weights = [0.6, 0.2, 0.2];
    labels = ["NewRoute", "ReturnHome", "LoiterEnd"];
    if isfield(fw, 'finalPhase') && isfield(fw.finalPhase, 'strategyWeights')
        if isfield(fw.finalPhase.strategyWeights, 'NewRoute')
            weights = [fw.finalPhase.strategyWeights.NewRoute, ...
                fw.finalPhase.strategyWeights.ReturnHome, ...
                fw.finalPhase.strategyWeights.LoiterEnd];
        else
            weights = [fw.finalPhase.strategyWeights.Exit, ...
                fw.finalPhase.strategyWeights.ReturnHome, ...
                fw.finalPhase.strategyWeights.LoiterEnd];
        end
    end
end
weights = max(weights, 0);
weights = weights / sum(weights);
r = rand();
if r < weights(1)
    strategy = labels(1);
elseif r < weights(1) + weights(2)
    strategy = labels(2);
else
    strategy = labels(3);
end
end

function level = nearestFlightLevel(altitude, fw)
if isfield(fw, 'flightLevel') && fw.flightLevel.enabled
    levels = fw.flightLevel.levelRange(1):fw.flightLevel.levelSpacing:fw.flightLevel.levelRange(2);
    [~, idx] = min(abs(levels - altitude));
    level = levels(idx);
else
    level = altitude;
end
end

function value = getNavValue(fw, fieldName, defaultValue)
if isfield(fw, 'navigation') && isfield(fw.navigation, fieldName)
    value = fw.navigation.(fieldName);
else
    value = defaultValue;
end
end

function value = sampleRange(range)
value = range(1) + rand() * (range(2) - range(1));
end

function value = sampleSignedRange(range)
magnitude = sampleRange(range);
if rand() < 0.5
    value = -magnitude;
else
    value = magnitude;
end
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
