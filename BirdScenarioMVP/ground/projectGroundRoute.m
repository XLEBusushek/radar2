function projection = projectGroundRoute(point, route, minDistanceAlong)
% projectGroundRoute - Проекция точки на ближайшую точку полилинии маршрута.
arguments
    point (3, 1) double
    route (1, 1) struct
    minDistanceAlong (1, 1) double = 0
end

points = route.Points;
cumulative = route.CumulativeDistance(:);

bestDistance = inf;
bestPosition = points(1, :).';
bestAlong = 0;
bestSegment = 1;
bestRoadID = route.RoadIDs(1);

for i = 1:(size(points, 1) - 1)
    [projXY, frac] = projectToSegment(point(1:2).', points(i, 1:2), points(i + 1, 1:2));
    along = cumulative(i) + frac * (cumulative(i + 1) - cumulative(i));
    if along + 1e-6 < minDistanceAlong
        continue;
    end
    dist = norm(projXY(:) - point(1:2));
    if dist < bestDistance
        bestDistance = dist;
        bestPosition = [projXY(:); 0];
        bestAlong = along;
        bestSegment = i;
        bestRoadID = route.RoadIDs(i);
    end
end

projection.Position = bestPosition;
projection.DistanceToRoute = bestDistance;
projection.DistanceAlong = bestAlong;
projection.SegmentIndex = bestSegment;
projection.RoadID = bestRoadID;
end

function [proj, frac] = projectToSegment(p, a, b)
ab = b - a;
den = dot(ab, ab);
if den <= 1e-9
    frac = 0;
else
    frac = dot(p - a, ab) / den;
end
frac = min(max(frac, 0), 1);
proj = a + frac * ab;
end
