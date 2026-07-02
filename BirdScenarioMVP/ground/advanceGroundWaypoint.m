function target = advanceGroundWaypoint(target, config)
% advanceGroundWaypoint - Move ground vehicle to next route waypoint.
arguments
    target (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
end

idx = target.Payload.CurrentWaypointIndex + 1;
numWaypoints = size(target.Payload.Waypoints, 1);
if idx > numWaypoints
    target.Payload.MissionComplete = true;
    target.Payload.LastNavigationEvent = "missionComplete";
    return;
end

target.Payload.CurrentWaypointIndex = idx;
target.Payload.CurrentWaypoint = target.Payload.Waypoints(idx, :).';
target.Payload.CurrentRoadID = target.Payload.WaypointRoadIDs(idx);
if isfield(target.Payload, 'WaypointEdgeIDs')
    target.Payload.CurrentEdgeID = target.Payload.WaypointEdgeIDs(idx);
end
target.Payload.RouteRoadID = target.Payload.CurrentRoadID;
target.Payload.SpeedLimit = target.Payload.WaypointSpeedLimits(idx);
if isfield(target.Payload, 'WaypointRouteDistances')
    target.Payload.DistanceToWaypoint = max(0, ...
        target.Payload.WaypointRouteDistances(idx) - target.Payload.RouteProgress);
else
    target.Payload.DistanceToWaypoint = norm(target.Payload.CurrentWaypoint(:) - target.Position(:));
end
target.Payload.LastNavigationEvent = "nextWaypoint";
end
