function route = findRoadRoute(roadNetwork, startNodeID, endNodeID)
% findRoadRoute - Поиск кратчайшего маршрута между узлами графа с помощью Дейкстры.
arguments
    roadNetwork (1, 1) struct
    startNodeID (1, 1) double {mustBePositive, mustBeInteger}
    endNodeID (1, 1) double {mustBePositive, mustBeInteger}
end

numNodes = numel(roadNetwork.Nodes);
dist = inf(numNodes, 1);
prev = zeros(numNodes, 1);
visited = false(numNodes, 1);
dist(startNodeID) = 0;

for iter = 1:numNodes
    candidates = find(~visited);
    if isempty(candidates)
        break;
    end
    [~, relIdx] = min(dist(candidates));
    current = candidates(relIdx);
    if isinf(dist(current)) || current == endNodeID
        break;
    end
    visited(current) = true;
    neighbors = roadNetwork.Adjacency{current};
    for k = 1:numel(neighbors)
        nb = neighbors(k);
        edge = getEdgeBetween(roadNetwork.Edges, current, nb);
        alt = dist(current) + edge.Length;
        if alt < dist(nb)
            dist(nb) = alt;
            prev(nb) = current;
        end
    end
end

if isinf(dist(endNodeID))
    route = emptyRoute(startNodeID);
    return;
end

nodeIDs = endNodeID;
while nodeIDs(1) ~= startNodeID
    nodeIDs = [prev(nodeIDs(1)), nodeIDs]; %#ok<AGROW>
end

edgeIDs = zeros(1, numel(nodeIDs) - 1);
points = zeros(0, 3);
for i = 1:(numel(nodeIDs) - 1)
    edge = getEdgeBetween(roadNetwork.Edges, nodeIDs(i), nodeIDs(i + 1));
    edgeIDs(i) = edge.ID;
    edgePoints = orientEdgePoints(edge, nodeIDs(i), nodeIDs(i + 1));
    if isempty(points)
        points = edgePoints;
    else
        points = [points; edgePoints(2:end, :)]; %#ok<AGROW>
    end
end

route.NodeIDs = nodeIDs(:).';
route.EdgeIDs = edgeIDs(:).';
route.Points = points;
route.Length = computeRoadLength(points);
route.CumulativeDistance = [0; cumsum(vecnorm(diff(points(:, 1:2), 1, 1), 2, 2))];
route.CurrentDistance = 0;
end

function route = emptyRoute(nodeID)
route.NodeIDs = nodeID;
route.EdgeIDs = [];
route.Points = zeros(0, 3);
route.Length = 0;
route.CumulativeDistance = 0;
route.CurrentDistance = 0;
end

function edge = getEdgeBetween(edges, a, b)
idx = find(([edges.StartNodeID] == a & [edges.EndNodeID] == b) | ...
    ([edges.StartNodeID] == b & [edges.EndNodeID] == a), 1, 'first');
if isempty(idx)
    error('findRoadRoute:MissingEdge', 'No edge between node %d and node %d.', a, b);
end
edge = edges(idx);
end

function points = orientEdgePoints(edge, startNodeID, endNodeID)
if edge.StartNodeID == startNodeID && edge.EndNodeID == endNodeID
    points = edge.Points;
else
    points = flipud(edge.Points);
end
end
