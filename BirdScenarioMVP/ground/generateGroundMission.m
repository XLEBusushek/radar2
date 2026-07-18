function mission = generateGroundMission(roadNetwork, config)
% generateGroundMission - Генерация миссии с маршрутизацией по графу для наземного транспорта.
arguments
    roadNetwork (1, 1) struct
    config (1, 1) struct
end

gv = config.groundVehicle;
numWaypoints = randi(gv.waypointCountRange);
homeSample = sampleRoadPoint(roadNetwork);
route = buildGraphRoute(roadNetwork, config, homeSample);

waypoints = zeros(numWaypoints, 3);
roadIds = zeros(numWaypoints, 1);
edgeIds = zeros(numWaypoints, 1);
speedLimits = zeros(numWaypoints, 1);
routeDistances = linspace(route.Length / (numWaypoints + 1), route.Length, numWaypoints);
for i = 1:numWaypoints
    rp = getGroundRoutePoint(route, routeDistances(i));
    nearest = findNearestRoadPoint(rp.Position(:), roadNetwork);
    waypoints(i, :) = nearest.Position(:).';
    roadIds(i) = nearest.RoadID;
    edgeIds(i) = nearest.EdgeID;
    speedLimits(i) = getEdgeByID(roadNetwork, nearest.EdgeID).SpeedLimit;
end

mission.HomePosition = homeSample.Position(:);
mission.Waypoints = waypoints;
mission.WaypointRoadIDs = roadIds;
mission.WaypointEdgeIDs = edgeIds;
mission.WaypointSpeedLimits = speedLimits;
mission.WaypointRouteDistances = routeDistances(:);
mission.Route = route;
mission.RoadRoute = route.RoadRoute;
mission.CurrentWaypointIndex = 1;
mission.CurrentWaypoint = waypoints(1, :).';
mission.CurrentRoadID = roadIds(1);
mission.CurrentEdgeID = edgeIds(1);
mission.CurrentRoadIndex = find([roadNetwork.Roads.ID] == roadIds(1), 1, 'first');
mission.CurrentSpeedLimit = speedLimits(1);
mission.RouteDestinationNodeID = route.DestinationNodeID;
end

function route = buildGraphRoute(roadNetwork, config, homeSample)
startEdge = getEdgeByID(roadNetwork, homeSample.EdgeID);
startNodeID = startEdge.EndNodeID;
bestRoute = [];
bestLength = -inf;
for attempt = 1:50
    endNodeID = chooseDestinationNode(roadNetwork, startNodeID, config);
    graphRoute = findRoadRoute(roadNetwork, startNodeID, endNodeID);
    if isempty(graphRoute.Points)
        continue;
    end
    [points, edgeIDs] = prependStartSegment(homeSample, startEdge, graphRoute);
    routeLength = computeRoadLength(points);
    candidate = makeRouteStruct(roadNetwork, points, edgeIDs, graphRoute, startNodeID, endNodeID);
    if routeLength > bestLength
        bestLength = routeLength;
        bestRoute = candidate;
    end
    if routeLength >= config.ground.route.minRouteLength && ...
            routeLength <= config.ground.route.maxRouteLength
        route = candidate;
        return;
    end
end

if isempty(bestRoute)
    endNodeID = startEdge.StartNodeID;
    graphRoute = findRoadRoute(roadNetwork, startNodeID, endNodeID);
    [points, edgeIDs] = prependStartSegment(homeSample, startEdge, graphRoute);
    bestRoute = makeRouteStruct(roadNetwork, points, edgeIDs, graphRoute, startNodeID, endNodeID);
end
route = bestRoute;
end

function [points, edgeIDs] = prependStartSegment(homeSample, startEdge, graphRoute)
points = homeSample.Position(:).';
startIdx = min(max(homeSample.SegmentIndex + 1, 2), size(startEdge.Points, 1));
points = [points; startEdge.Points(startIdx:end, :)];
edgeIDs = startEdge.ID;
if ~isempty(graphRoute.Points)
    if norm(graphRoute.Points(1, 1:2) - points(end, 1:2)) < 1e-6
        points = [points; graphRoute.Points(2:end, :)];
    else
        points = [points; graphRoute.Points];
    end
    edgeIDs = [edgeIDs, graphRoute.EdgeIDs];
end
end

function route = makeRouteStruct(roadNetwork, points, edgeIDs, graphRoute, startNodeID, endNodeID)
cumulative = [0; cumsum(vecnorm(diff(points(:, 1:2), 1, 1), 2, 2))];
segmentEdgeIDs = edgeIDsForRouteSegments(roadNetwork, points, edgeIDs);
route.Points = points;
route.RoutePoints = points;
route.EdgeIDs = segmentEdgeIDs(:);
route.RoadIDs = arrayfun(@(edgeID) getEdgeByID(roadNetwork, edgeID).RoadID, route.EdgeIDs);
route.RoadSpeedLimits = arrayfun(@(edgeID) getEdgeByID(roadNetwork, edgeID).SpeedLimit, route.EdgeIDs);
route.CumulativeDistance = cumulative;
route.CurrentDistance = 0;
route.Length = cumulative(end);
route.CurrentSegmentIndex = 1;
route.LookaheadPoint = points(min(2, size(points, 1)), :).';
route.OnRoad = true;
route.ReturnDistance = 0;
route.RoadRoute = graphRoute;
route.RoadRoute.NodeIDs = uniqueStable([startNodeID, graphRoute.NodeIDs]);
route.RoadRoute.EdgeIDs = edgeIDs(:).';
route.RoadRoute.Points = points;
route.RoadRoute.Length = route.Length;
route.DestinationNodeID = endNodeID;
end

function segmentEdgeIDs = edgeIDsForRouteSegments(roadNetwork, points, routeEdgeIDs)
segmentCount = max(1, size(points, 1) - 1);
segmentEdgeIDs = zeros(segmentCount, 1);
for i = 1:segmentCount
    mid = 0.5 * (points(i, :) + points(i + 1, :));
    segmentEdgeIDs(i) = nearestRouteEdgeID(mid, roadNetwork, routeEdgeIDs);
end
end

function edgeID = nearestRouteEdgeID(point, roadNetwork, routeEdgeIDs)
edgeID = routeEdgeIDs(1);
bestDistance = inf;
for i = 1:numel(routeEdgeIDs)
    edge = getEdgeByID(roadNetwork, routeEdgeIDs(i));
    distance = distanceToPolyline(point(1:2), edge.Points(:, 1:2));
    if distance < bestDistance
        bestDistance = distance;
        edgeID = edge.ID;
    end
end
end

function distance = distanceToPolyline(point, points)
distance = inf;
for i = 1:(size(points, 1) - 1)
    proj = projectToSegment(point, points(i, :), points(i + 1, :));
    distance = min(distance, norm(proj(:).' - point(1:2)));
end
end

function proj = projectToSegment(point, a, b)
ab = b - a;
den = dot(ab, ab);
if den <= 1e-9
    frac = 0;
else
    frac = dot(point - a, ab) / den;
end
frac = min(max(frac, 0), 1);
proj = a + frac * ab;
end

function endNodeID = chooseDestinationNode(roadNetwork, startNodeID, config)
nodes = roadNetwork.Nodes;
startPos = nodes(startNodeID).Position(:);
distances = arrayfun(@(n) norm(n.Position(1:2) - startPos(1:2)), nodes);
minDistance = config.ground.route.minNodeDistance * 100;
candidates = find(distances >= minDistance);
if isempty(candidates)
    candidates = setdiff(1:numel(nodes), startNodeID);
end
endNodeID = candidates(randi(numel(candidates)));
end

function edge = getEdgeByID(roadNetwork, edgeID)
idx = find([roadNetwork.Edges.ID] == edgeID, 1, 'first');
edge = roadNetwork.Edges(idx);
end

function values = uniqueStable(values)
[~, idx] = unique(values, 'stable');
values = values(sort(idx));
end
