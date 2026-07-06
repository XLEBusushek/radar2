function exitPoint = selectExitPoint(lastWaypoint, previousWaypoint, worldSize, fw)
% selectExitPoint - Choose a smooth boundary exit point for fixed-wing missions.
arguments
    lastWaypoint (3, 1) double
    previousWaypoint (3, 1) double
    worldSize (1, 3) double
    fw (1, 1) struct
end

margin = getNavigationValue(fw, 'boundaryMargin', 120);
minDistance = getFinalPhaseValue(fw, 'minExitDistanceFromLastWaypoint', 400);
cornerFraction = getFinalPhaseValue(fw, 'cornerAvoidanceFraction', 0.12);

routeDirection = lastWaypoint(1:2) - previousWaypoint(1:2);
if norm(routeDirection) < 1e-6
    routeDirection = [1; 0];
else
    routeDirection = routeDirection / norm(routeDirection);
end

bestPoint = [];
bestScore = -inf;
for attempt = 1:24
    candidate = candidateExitPoint(lastWaypoint, routeDirection, worldSize, margin, cornerFraction);
    if norm(candidate(1:2) - lastWaypoint(1:2)) < minDistance
        continue;
    end
    turnDeg = routeTurnDeg(routeDirection, candidate(1:2) - lastWaypoint(1:2));
    score = -turnDeg + 0.001 * norm(candidate(1:2) - lastWaypoint(1:2));
    if score > bestScore
        bestScore = score;
        bestPoint = candidate;
    end
end

if isempty(bestPoint)
    bestPoint = extendAlongRoute(lastWaypoint, routeDirection, worldSize, margin);
end

exitPoint = validateExitPoint(bestPoint, lastWaypoint, worldSize, fw);
end

function candidate = candidateExitPoint(lastWaypoint, routeDirection, worldSize, margin, cornerFraction)
edgeIdx = randi(4);
span = max(worldSize(1), worldSize(2));
cornerBand = cornerFraction * span;

switch edgeIdx
    case 1
        y = margin + cornerBand + rand() * max(worldSize(2) - 2 * (margin + cornerBand), 1);
        candidate = [margin; y; lastWaypoint(3)];
    case 2
        y = margin + cornerBand + rand() * max(worldSize(2) - 2 * (margin + cornerBand), 1);
        candidate = [worldSize(1) - margin; y; lastWaypoint(3)];
    case 3
        x = margin + cornerBand + rand() * max(worldSize(1) - 2 * (margin + cornerBand), 1);
        candidate = [x; margin; lastWaypoint(3)];
    otherwise
        x = margin + cornerBand + rand() * max(worldSize(1) - 2 * (margin + cornerBand), 1);
        candidate = [x; worldSize(2) - margin; lastWaypoint(3)];
end

routeTarget = lastWaypoint(1:2) + routeDirection * norm(candidate(1:2) - lastWaypoint(1:2));
blend = 0.35 + 0.25 * rand();
candidate(1:2) = blend * candidate(1:2) + (1 - blend) * routeTarget;
candidate(1) = min(max(candidate(1), margin), worldSize(1) - margin);
candidate(2) = min(max(candidate(2), margin), worldSize(2) - margin);
end

function exitPoint = extendAlongRoute(lastWaypoint, routeDirection, worldSize, margin)
maxDistance = distanceToInnerBounds(lastWaypoint(1:2), routeDirection, worldSize, margin);
distance = max(maxDistance * 0.9, 0);
xy = lastWaypoint(1:2) + routeDirection * distance;
xy(1) = min(max(xy(1), margin), worldSize(1) - margin);
xy(2) = min(max(xy(2), margin), worldSize(2) - margin);
exitPoint = [xy; lastWaypoint(3)];
end

function turnDeg = routeTurnDeg(fromDirection, toVector)
if norm(toVector) < 1e-6
    turnDeg = 180;
    return;
end
heading = atan2(toVector(2), toVector(1));
fromHeading = atan2(fromDirection(2), fromDirection(1));
turnDeg = abs(wrapToPiLocal(heading - fromHeading)) * 180 / pi;
end

function maxDistance = distanceToInnerBounds(point, direction, worldSize, margin)
limits = [];
if direction(1) > 1e-9
    limits(end + 1) = (worldSize(1) - margin - point(1)) / direction(1); %#ok<AGROW>
elseif direction(1) < -1e-9
    limits(end + 1) = (margin - point(1)) / direction(1); %#ok<AGROW>
end
if direction(2) > 1e-9
    limits(end + 1) = (worldSize(2) - margin - point(2)) / direction(2); %#ok<AGROW>
elseif direction(2) < -1e-9
    limits(end + 1) = (margin - point(2)) / direction(2); %#ok<AGROW>
end
limits = limits(limits > 0);
if isempty(limits)
    maxDistance = 0;
else
    maxDistance = min(limits);
end
end

function value = getNavigationValue(fw, fieldName, defaultValue)
if isfield(fw, 'navigation') && isfield(fw.navigation, fieldName)
    value = fw.navigation.(fieldName);
else
    value = defaultValue;
end
end

function value = getFinalPhaseValue(fw, fieldName, defaultValue)
if isfield(fw, 'finalPhase') && isfield(fw.finalPhase, fieldName)
    value = fw.finalPhase.(fieldName);
else
    value = defaultValue;
end
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
