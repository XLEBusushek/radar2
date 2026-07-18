function target = advanceQuadcopterWaypoint(target, config)
% advanceQuadcopterWaypoint - Перейти к следующей точке после прибытия.
if nargin >= 2
    target = selectNextQuadcopterWaypoint(target, config);
    return;
end

idx = target.Payload.CurrentWaypointIndex + 1;
numWaypoints = size(target.Payload.Waypoints, 1);

if idx > numWaypoints
    return;
end

target.Payload.CurrentWaypointIndex = idx;
target.Payload.CurrentWaypoint = target.Payload.Waypoints(idx, :).';
target.Payload.DistanceToWaypoint = norm(target.Payload.CurrentWaypoint(:) - target.Position);
target = resetQuadcopterNavigationFlags(target);
target.Payload.LastNavigationEvent = "nextWaypoint";
end
