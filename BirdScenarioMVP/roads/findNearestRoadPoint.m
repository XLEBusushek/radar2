function nearest = findNearestRoadPoint(position, roadNetwork)
% findNearestRoadPoint - Поиск ближайшей точки на любом рёбре графа дорог.
arguments
    position (3, 1) double
    roadNetwork (1, 1) struct
end

best.Distance = inf;
best.Position = position(:);
best.EdgeID = nan;
best.RoadID = nan;
best.S = nan;
best.Direction = [1; 0; 0];
best.NodeID = nan;

for i = 1:numel(roadNetwork.Edges)
    edge = roadNetwork.Edges(i);
    cumulative = [0; cumsum(vecnorm(diff(edge.Points(:, 1:2), 1, 1), 2, 2))];
    for s = 1:(size(edge.Points, 1) - 1)
        [proj, frac] = projectToSegment(position(1:2).', edge.Points(s, 1:2), edge.Points(s + 1, 1:2));
        dist = norm(proj(:) - position(1:2));
        if dist < best.Distance
            dir = edge.Points(s + 1, :) - edge.Points(s, :);
            if norm(dir(1:2)) < 1e-9
                dir = [1, 0, 0];
            else
                dir = dir / norm(dir(1:2));
            end
            best.Distance = dist;
            best.Position = [proj(:); 0];
            best.EdgeID = edge.ID;
            best.RoadID = edge.RoadID;
            best.S = cumulative(s) + frac * (cumulative(s + 1) - cumulative(s));
            best.Direction = dir(:);
            best.Direction(3) = 0;
            best.NodeID = edge.StartNodeID;
        end
    end
end

nearest = best;
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
