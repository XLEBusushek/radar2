function target = returnToRoad(target, roadNetwork)
% returnToRoad - Select nearest road point as return target.
arguments
    target (1, 1) struct
    roadNetwork (1, 1) struct
end

if isfield(target.Payload, 'Route') && ~isempty(target.Payload.Route.Points)
    returnDistance = target.Payload.ReturnRouteDistance;
    if isempty(returnDistance) || returnDistance <= 0
        projection = projectGroundRoute(target.Position(:), target.Payload.Route, target.Payload.RouteProgress);
        returnDistance = max(projection.DistanceAlong, target.Payload.RouteProgress);
    end
    routePoint = getGroundRoutePoint(target.Payload.Route, returnDistance);
    nearest = findNearestRoadPoint(routePoint.Position(:), roadNetwork);
    target.Payload.ReturnRouteDistance = returnDistance;
    target.Payload.ReturnRoadPoint = nearest.Position(:);
    target.Payload.CurrentRoadID = nearest.RoadID;
    target.Payload.CurrentEdgeID = nearest.EdgeID;
    target.Payload.RouteRoadID = nearest.RoadID;
    target.Payload.SpeedLimit = getRouteSpeedLimit(target.Payload.Route, nearest.EdgeID, target.Payload.SpeedLimit);
else
    nearest = findNearestRoad(target.Position(:), roadNetwork);
    target.Payload.ReturnRoadPoint = nearest.Position(:);
    target.Payload.CurrentRoadID = nearest.RoadID;
    target.Payload.CurrentRoadIndex = nearest.RoadIndex;
    target.Payload.SpeedLimit = nearest.SpeedLimit;
end
target.Payload.LastDecision = "ReturnRoad";
target.Payload.GroundAction = "ReturnRoad";
target.Payload.LastNavigationEvent = "returnRoad";
end

function speedLimit = getRouteSpeedLimit(route, edgeID, defaultSpeedLimit)
speedLimit = defaultSpeedLimit;
idx = find(route.EdgeIDs == edgeID, 1, 'first');
if isfield(route, 'RoadSpeedLimits') && ~isempty(idx) && numel(route.RoadSpeedLimits) >= idx
    speedLimit = route.RoadSpeedLimits(idx);
end
end
