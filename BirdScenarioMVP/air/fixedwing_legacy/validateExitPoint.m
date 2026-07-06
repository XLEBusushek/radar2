function exitPoint = validateExitPoint(exitPoint, lastWaypoint, worldSize, fw)
% validateExitPoint - Ensure exit point is inside bounds and far enough from route end.
arguments
    exitPoint (3, 1) double
    lastWaypoint (3, 1) double
    worldSize (1, 3) double
    fw (1, 1) struct
end

margin = getNavigationValue(fw, 'boundaryMargin', 120);
minDistance = getFinalPhaseValue(fw, 'minExitDistanceFromLastWaypoint', 400);
cornerFraction = getFinalPhaseValue(fw, 'cornerAvoidanceFraction', 0.12);

exitPoint = exitPoint(:);
exitPoint(1) = min(max(exitPoint(1), margin), worldSize(1) - margin);
exitPoint(2) = min(max(exitPoint(2), margin), worldSize(2) - margin);
exitPoint(3) = min(max(exitPoint(3), fw.operatingAltitudeRange(1)), fw.operatingAltitudeRange(2));

span = max(worldSize(1), worldSize(2));
cornerBand = cornerFraction * span;
if exitPoint(1) <= margin + cornerBand && exitPoint(2) <= margin + cornerBand
    exitPoint(1:2) = [margin + cornerBand; margin + cornerBand * 1.5];
elseif exitPoint(1) <= margin + cornerBand && exitPoint(2) >= worldSize(2) - margin - cornerBand
    exitPoint(1:2) = [margin + cornerBand; worldSize(2) - margin - cornerBand * 1.5];
elseif exitPoint(1) >= worldSize(1) - margin - cornerBand && exitPoint(2) <= margin + cornerBand
    exitPoint(1:2) = [worldSize(1) - margin - cornerBand; margin + cornerBand * 1.5];
elseif exitPoint(1) >= worldSize(1) - margin - cornerBand && ...
        exitPoint(2) >= worldSize(2) - margin - cornerBand
    exitPoint(1:2) = [worldSize(1) - margin - cornerBand; worldSize(2) - margin - cornerBand * 1.5];
end

if norm(exitPoint(1:2) - lastWaypoint(1:2)) < minDistance
    direction = exitPoint(1:2) - lastWaypoint(1:2);
    if norm(direction) < 1e-6
        direction = [1; 0];
    else
        direction = direction / norm(direction);
    end
    exitPoint(1:2) = lastWaypoint(1:2) + direction * minDistance;
    exitPoint(1) = min(max(exitPoint(1), margin), worldSize(1) - margin);
    exitPoint(2) = min(max(exitPoint(2), margin), worldSize(2) - margin);
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
