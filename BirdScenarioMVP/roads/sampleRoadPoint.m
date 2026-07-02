function sample = sampleRoadPoint(roadNetwork, varargin)
% sampleRoadPoint - Sample a random point on a road polyline.
arguments
    roadNetwork (1, 1) struct
end
arguments (Repeating)
    varargin
end

edges = roadNetwork.Edges;
if isempty(edges)
    error('sampleRoadPoint:EmptyNetwork', 'Road network contains no roads.');
end

edgeId = nan;
if ~isempty(varargin)
    edgeId = varargin{1};
end

if isnan(edgeId)
    edgeIdx = weightedEdgeSample(edges);
else
    edgeIdx = find([edges.ID] == edgeId | [edges.RoadID] == edgeId, 1, 'first');
    if isempty(edgeIdx)
        error('sampleRoadPoint:EdgeNotFound', 'Edge/Road ID %g was not found.', edgeId);
    end
end

edge = edges(edgeIdx);
[point, distanceAlong, segmentIndex, direction] = samplePointOnPolyline(edge.Points);
sample.Position = point(:);
sample.EdgeID = edge.ID;
sample.NodeID = edge.StartNodeID;
sample.RoadID = edge.RoadID;
sample.RoadIndex = edgeIdx;
sample.S = distanceAlong;
sample.DistanceAlong = distanceAlong;
sample.SegmentIndex = segmentIndex;
sample.Direction = direction(:);
sample.SpeedLimit = edge.SpeedLimit;
end

function edgeIdx = weightedEdgeSample(edges)
lengths = [edges.Length];
total = sum(lengths);
if total <= 0
    edgeIdx = randi(numel(edges));
    return;
end
r = rand() * total;
edgeIdx = find(r <= cumsum(lengths), 1, 'first');
if isempty(edgeIdx)
    edgeIdx = numel(edges);
end
end

function [point, distanceAlong, segmentIndex, direction] = samplePointOnPolyline(points)
segments = diff(points(:, 1:2), 1, 1);
lengths = vecnorm(segments, 2, 2);
totalLength = sum(lengths);
if totalLength <= 0
    point = points(1, :).';
    distanceAlong = 0;
    segmentIndex = 1;
    direction = [1; 0; 0];
    return;
end

distanceAlong = rand() * totalLength;
remaining = distanceAlong;
segmentIndex = numel(lengths);
for i = 1:numel(lengths)
    if remaining <= lengths(i)
        segmentIndex = i;
        break;
    end
    remaining = remaining - lengths(i);
end

ratio = remaining / max(lengths(segmentIndex), 1e-9);
point = points(segmentIndex, :) + ratio * (points(segmentIndex + 1, :) - points(segmentIndex, :));
point = point(:);
point(3) = 0;
dir = points(segmentIndex + 1, :) - points(segmentIndex, :);
if norm(dir(1:2)) < 1e-9
    direction = [1; 0; 0];
else
    direction = (dir(:) / norm(dir(1:2)));
    direction(3) = 0;
end
end
