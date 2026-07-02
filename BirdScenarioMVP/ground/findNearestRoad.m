function nearest = findNearestRoad(point, roadNetwork)
% findNearestRoad - Project a point to the nearest road segment.
arguments
    point (3, 1) double
    roadNetwork (1, 1) struct
end

nearestPoint = findNearestRoadPoint(point, roadNetwork);
nearest.Distance = nearestPoint.Distance;
nearest.Position = nearestPoint.Position;
nearest.RoadID = nearestPoint.RoadID;
nearest.EdgeID = nearestPoint.EdgeID;
nearest.NodeID = nearestPoint.NodeID;
nearest.S = nearestPoint.S;
nearest.Direction = nearestPoint.Direction;
nearest.RoadIndex = find([roadNetwork.Roads.ID] == nearestPoint.RoadID, 1, 'first');
nearest.SegmentIndex = nan;
nearest.SpeedLimit = nan;
edgeIdx = find([roadNetwork.Edges.ID] == nearestPoint.EdgeID, 1, 'first');
if ~isempty(edgeIdx)
    nearest.SpeedLimit = roadNetwork.Edges(edgeIdx).SpeedLimit;
end
nearest.DistanceAlong = nearestPoint.S;
end
