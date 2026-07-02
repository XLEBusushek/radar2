function routePoint = getGroundRoutePoint(route, distanceAlong)
% getGroundRoutePoint - Sample a point/tangent on a ground route polyline.
arguments
    route (1, 1) struct
    distanceAlong (1, 1) double
end

points = route.Points;
cumulative = route.CumulativeDistance(:);
if isempty(points) || size(points, 1) == 1
    routePoint.Position = points(1, :).';
    routePoint.Tangent = [1; 0; 0];
    routePoint.SegmentIndex = 1;
    routePoint.RoadID = route.RoadIDs(1);
    routePoint.EdgeID = getRouteEdgeID(route, 1);
    routePoint.DistanceAlong = 0;
    return;
end

distanceAlong = min(max(distanceAlong, 0), cumulative(end));
idx = find(cumulative <= distanceAlong, 1, 'last');
idx = min(max(idx, 1), size(points, 1) - 1);
segLen = cumulative(idx + 1) - cumulative(idx);
ratio = 0;
if segLen > 1e-9
    ratio = (distanceAlong - cumulative(idx)) / segLen;
end

position = points(idx, :) + ratio * (points(idx + 1, :) - points(idx, :));
tangent = points(idx + 1, :) - points(idx, :);
if norm(tangent(1:2)) < 1e-9
    tangent = [1, 0, 0];
else
    tangent = tangent / norm(tangent(1:2));
end

routePoint.Position = position(:);
routePoint.Tangent = tangent(:);
routePoint.SegmentIndex = idx;
routePoint.RoadID = route.RoadIDs(idx);
routePoint.EdgeID = getRouteEdgeID(route, idx);
routePoint.DistanceAlong = distanceAlong;
end

function edgeID = getRouteEdgeID(route, idx)
if isfield(route, 'EdgeIDs') && ~isempty(route.EdgeIDs)
    edgeID = route.EdgeIDs(min(idx, numel(route.EdgeIDs)));
else
    edgeID = idx;
end
end
