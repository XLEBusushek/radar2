function distance = computeFixedWingWaypointDistance(target)
% computeFixedWingWaypointDistance - Horizontal distance to active waypoint.
arguments
    target (1, 1) struct
end

delta = target.Payload.CurrentWaypoint(:) - target.Position(:);
distance = norm(delta(1:2));
end
