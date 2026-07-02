function roadNetwork = buildRoadGraph(roads, config)
% buildRoadGraph - Convert road polylines into graph nodes, edges, adjacency.
arguments
    roads (1, :) struct
    config (1, 1) struct
end

nodeRecords = collectNodeRecords(roads, config);
[nodes, roadNodeRefs] = mergeNodeRecords(nodeRecords, config);
edges = buildEdgesFromRoadNodes(roads, nodes, roadNodeRefs);
[adjacency, nodes] = buildAdjacency(nodes, edges);

roadNetwork.Nodes = nodes;
roadNetwork.Edges = edges;
roadNetwork.Adjacency = adjacency;
roadNetwork.MainRoadIDs = [roads(string({roads.Type}) == "main").ID];
roadNetwork.SecondaryRoadIDs = [roads(string({roads.Type}) ~= "main").ID];
roadNetwork.Bounds = [0, config.world.size(1); 0, config.world.size(2); 0, 0];
roadNetwork.Roads = roads;
roadNetwork.Paths = edges;
roadNetwork.Intersections = makeLegacyIntersections(nodes, edges);
roadNetwork.Metadata.RoadCount = numel(roads);
roadNetwork.Metadata.EdgeCount = numel(edges);
roadNetwork.Metadata.NodeCount = numel(nodes);
roadNetwork.Metadata.IntersectionCount = numel(roadNetwork.Intersections);
roadNetwork.Metadata.TotalLength = sum([edges.Length]);
roadNetwork.Metadata.CreatedBy = "buildRoadGraph";
end

function intersections = makeLegacyIntersections(nodes, edges)
intersections = struct('ID', {}, 'Position', {}, 'RoadIDs', {}, 'EdgeIDs', {});
nodeTypes = string({nodes.Type});
intersectionNodes = nodes(nodeTypes == "intersection");
for i = 1:numel(intersectionNodes)
    edgeIDs = intersectionNodes(i).ConnectedEdges;
    roadIDs = [];
    for k = 1:numel(edgeIDs)
        edgeIdx = find([edges.ID] == edgeIDs(k), 1, 'first');
        if ~isempty(edgeIdx)
            roadIDs(end + 1) = edges(edgeIdx).RoadID; %#ok<AGROW>
        end
    end
    intersections(i).ID = intersectionNodes(i).ID; %#ok<AGROW>
    intersections(i).Position = intersectionNodes(i).Position; %#ok<AGROW>
    intersections(i).RoadIDs = unique(roadIDs); %#ok<AGROW>
    intersections(i).EdgeIDs = edgeIDs; %#ok<AGROW>
end
end

function records = collectNodeRecords(roads, config)
records = struct('RoadID', {}, 'Position', {}, 'DistanceAlong', {}, 'Type', {});
for i = 1:numel(roads)
    records(end + 1) = makeRecord(roads(i).ID, roads(i).Points(1, :), 0, "entry"); %#ok<AGROW>
    records(end + 1) = makeRecord(roads(i).ID, roads(i).Points(end, :), roads(i).Length, "exit"); %#ok<AGROW>
end

for i = 1:numel(roads)
    for j = (i + 1):numel(roads)
        for a = 1:(size(roads(i).Points, 1) - 1)
            for b = 1:(size(roads(j).Points, 1) - 1)
                [hit, xy, fracA, fracB] = segmentIntersection( ...
                    roads(i).Points(a, 1:2), roads(i).Points(a + 1, 1:2), ...
                    roads(j).Points(b, 1:2), roads(j).Points(b + 1, 1:2));
                if ~hit
                    continue;
                end
                distA = distanceToVertex(roads(i).Points, a) + ...
                    fracA * norm(roads(i).Points(a + 1, 1:2) - roads(i).Points(a, 1:2));
                distB = distanceToVertex(roads(j).Points, b) + ...
                    fracB * norm(roads(j).Points(b + 1, 1:2) - roads(j).Points(b, 1:2));
                pos = [xy(:).', 0];
                records(end + 1) = makeRecord(roads(i).ID, pos, distA, "intersection"); %#ok<AGROW>
                records(end + 1) = makeRecord(roads(j).ID, pos, distB, "intersection"); %#ok<AGROW>
            end
        end
    end
end

if isempty(records)
    return;
end

% Snap near-duplicate records so generated road endpoints become graph junctions.
tol = max(5, config.roads.intersectionTolerance);
for i = 1:numel(records)
    for j = (i + 1):numel(records)
        if norm(records(i).Position(1:2) - records(j).Position(1:2)) <= tol
            pos = 0.5 * (records(i).Position + records(j).Position);
            records(i).Position = pos;
            records(j).Position = pos;
            if records(i).RoadID ~= records(j).RoadID
                records(i).Type = "intersection";
                records(j).Type = "intersection";
            end
        end
    end
end
end

function record = makeRecord(roadID, position, distanceAlong, type)
record.RoadID = roadID;
record.Position = position(:).';
record.Position(3) = 0;
record.DistanceAlong = distanceAlong;
record.Type = string(type);
end

function [nodes, roadNodeRefs] = mergeNodeRecords(records, config)
tol = max(5, config.roads.intersectionTolerance);
nodes = struct('ID', {}, 'Position', {}, 'Type', {}, 'ConnectedEdges', {});
roadNodeRefs = struct('RoadID', {}, 'NodeID', {}, 'DistanceAlong', {});
for i = 1:numel(records)
    nodeID = findNode(nodes, records(i).Position, tol);
    if isempty(nodeID)
        nodeID = numel(nodes) + 1;
        nodes(nodeID).ID = nodeID; %#ok<AGROW>
        nodes(nodeID).Position = records(i).Position(:); %#ok<AGROW>
        nodes(nodeID).Type = records(i).Type; %#ok<AGROW>
        nodes(nodeID).ConnectedEdges = []; %#ok<AGROW>
    elseif records(i).Type == "intersection"
        nodes(nodeID).Type = "intersection";
    end
    roadNodeRefs(end + 1).RoadID = records(i).RoadID; %#ok<AGROW>
    roadNodeRefs(end).NodeID = nodeID;
    roadNodeRefs(end).DistanceAlong = records(i).DistanceAlong;
end
end

function nodeID = findNode(nodes, position, tol)
nodeID = [];
for i = 1:numel(nodes)
    if norm(nodes(i).Position(1:2) - position(1:2).') <= tol
        nodeID = i;
        return;
    end
end
end

function edges = buildEdgesFromRoadNodes(roads, nodes, roadNodeRefs)
edges = struct('ID', {}, 'StartNodeID', {}, 'EndNodeID', {}, 'Points', {}, ...
    'Length', {}, 'Width', {}, 'SpeedLimit', {}, 'Type', {}, 'Curvature', {}, ...
    'RoadID', {}, 'Intersections', {});
edgeID = 0;
for r = 1:numel(roads)
    refs = roadNodeRefs([roadNodeRefs.RoadID] == roads(r).ID);
    if isempty(refs)
        continue;
    end
    [~, order] = unique(round([refs.DistanceAlong] * 1000) / 1000, 'stable');
    refs = refs(order);
    [~, sortIdx] = sort([refs.DistanceAlong]);
    refs = refs(sortIdx);
    for i = 1:(numel(refs) - 1)
        if refs(i).NodeID == refs(i + 1).NodeID
            continue;
        end
        points = roadSectionPoints(roads(r), nodes(refs(i).NodeID).Position.', ...
            nodes(refs(i + 1).NodeID).Position.', refs(i).DistanceAlong, refs(i + 1).DistanceAlong);
        len = computeRoadLength(points);
        if len < 1e-6
            continue;
        end
        edgeID = edgeID + 1;
        edges(edgeID).ID = edgeID; %#ok<AGROW>
        edges(edgeID).StartNodeID = refs(i).NodeID;
        edges(edgeID).EndNodeID = refs(i + 1).NodeID;
        edges(edgeID).Points = points;
        edges(edgeID).Length = len;
        edges(edgeID).Width = roads(r).Width;
        edges(edgeID).SpeedLimit = roads(r).SpeedLimit;
        edges(edgeID).Type = roads(r).Type;
        edges(edgeID).Curvature = computeCurvature(points);
        edges(edgeID).RoadID = roads(r).ID;
        edges(edgeID).Intersections = [];
    end
end
end

function points = roadSectionPoints(road, startPoint, endPoint, startDistance, endDistance)
cumulative = [0; cumsum(vecnorm(diff(road.Points(:, 1:2), 1, 1), 2, 2))];
points = startPoint;
idx = find(cumulative > startDistance & cumulative < endDistance).';
for k = idx
    points(end + 1, :) = road.Points(k, :); %#ok<AGROW>
end
points(end + 1, :) = endPoint;
points(:, 3) = 0;
end

function curvature = computeCurvature(points)
curvature = 0;
if size(points, 1) < 3
    return;
end
for i = 1:(size(points, 1) - 2)
    v1 = points(i + 1, 1:2) - points(i, 1:2);
    v2 = points(i + 2, 1:2) - points(i + 1, 1:2);
    if norm(v1) < 1e-6 || norm(v2) < 1e-6
        continue;
    end
    curvature = curvature + abs(acos(min(max(dot(v1, v2) / (norm(v1) * norm(v2)), -1), 1)));
end
end

function [adjacency, nodes] = buildAdjacency(nodes, edges)
adjacency = cell(numel(nodes), 1);
for e = 1:numel(edges)
    a = edges(e).StartNodeID;
    b = edges(e).EndNodeID;
    adjacency{a} = unique([adjacency{a}, b]);
    adjacency{b} = unique([adjacency{b}, a]);
    nodes(a).ConnectedEdges(end + 1) = edges(e).ID;
    nodes(b).ConnectedEdges(end + 1) = edges(e).ID;
end
end

function d = distanceToVertex(points, idx)
if idx <= 1
    d = 0;
else
    d = sum(vecnorm(diff(points(1:idx, 1:2), 1, 1), 2, 2));
end
end

function [hit, xy, t, u] = segmentIntersection(p1, p2, q1, q2)
r = p2 - p1;
s = q2 - q1;
den = cross2d(r, s);
hit = false;
xy = [nan; nan];
t = nan;
u = nan;
if abs(den) < 1e-9
    return;
end
t = cross2d(q1 - p1, s) / den;
u = cross2d(q1 - p1, r) / den;
if t >= -1e-6 && t <= 1 + 1e-6 && u >= -1e-6 && u <= 1 + 1e-6
    xy = (p1 + t * r).';
    hit = true;
end
end

function c = cross2d(a, b)
c = a(1) * b(2) - a(2) * b(1);
end
