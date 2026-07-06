function inside = isWaypointInsideSafeZone(waypoint, config)
% isWaypointInsideSafeZone - True when XY lies inside the Safe Zone.
arguments
    waypoint (:, 1) double
    config (1, 1) struct
end

zones = getFixedWingZoneBounds(config);
safe = zones.SafeZone;
inside = waypoint(1) >= safe(1) && waypoint(1) <= safe(2) && ...
    waypoint(2) >= safe(3) && waypoint(2) <= safe(4);
end
