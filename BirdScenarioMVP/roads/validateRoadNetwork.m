function [isValid, report] = validateRoadNetwork(roadNetwork, config)
% validateRoadNetwork - Проверка качества дорожной сети на уровне графа.
arguments
    roadNetwork (1, 1) struct
    config (1, 1) struct
end

edges = roadNetwork.Edges;
nodes = roadNetwork.Nodes;
report.EdgeCount = numel(edges);
report.NodeCount = numel(nodes);
report.MainRoadCount = numel(roadNetwork.MainRoadIDs);
report.TotalLength = sum([edges.Length]);
report.ConnectedFraction = connectedEdgeFraction(roadNetwork);
report.MinRoadLength = inf;
if isfield(roadNetwork, 'Roads') && ~isempty(roadNetwork.Roads)
    report.MinRoadLength = min([roadNetwork.Roads.Length]);
end
report.PointsInBounds = pointsInBounds(roadNetwork, config.world.size);
report.IntersectionCount = sum(string({nodes.Type}) == "intersection");

isValid = report.MainRoadCount >= config.roads.mainRoadCountRange(1) && ...
    report.TotalLength >= config.roads.minTotalLength && ...
    report.ConnectedFraction >= config.roads.minConnectedFraction && ...
    report.MinRoadLength >= config.roads.minRoadLength && ...
    report.PointsInBounds && ...
    report.NodeCount >= config.roads.minNodeCount && ...
    report.IntersectionCount >= 3;
end

function fraction = connectedEdgeFraction(roadNetwork)
if isempty(roadNetwork.Edges)
    fraction = 0;
    return;
end
visitedNodes = false(numel(roadNetwork.Nodes), 1);
componentEdgeCounts = [];
for n = 1:numel(roadNetwork.Nodes)
    if visitedNodes(n)
        continue;
    end
    queue = n;
    visitedNodes(n) = true;
    componentNodes = [];
    while ~isempty(queue)
        current = queue(1);
        queue(1) = [];
        componentNodes(end + 1) = current; %#ok<AGROW>
        neighbors = roadNetwork.Adjacency{current};
        for k = 1:numel(neighbors)
            nb = neighbors(k);
            if ~visitedNodes(nb)
                visitedNodes(nb) = true;
                queue(end + 1) = nb; %#ok<AGROW>
            end
        end
    end
    count = sum(arrayfun(@(e) ismember(e.StartNodeID, componentNodes) && ...
        ismember(e.EndNodeID, componentNodes), roadNetwork.Edges));
    componentEdgeCounts(end + 1) = count; %#ok<AGROW>
end
fraction = max(componentEdgeCounts) / max(1, numel(roadNetwork.Edges));
end

function ok = pointsInBounds(roadNetwork, worldSize)
ok = true;
for e = 1:numel(roadNetwork.Edges)
    pts = roadNetwork.Edges(e).Points;
    if any(pts(:, 1) < 0 | pts(:, 1) > worldSize(1) | ...
            pts(:, 2) < 0 | pts(:, 2) > worldSize(2) | abs(pts(:, 3)) > 1e-9)
        ok = false;
        return;
    end
end
end
