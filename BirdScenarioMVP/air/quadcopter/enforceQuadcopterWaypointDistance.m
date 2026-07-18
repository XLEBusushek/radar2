function waypoint = enforceQuadcopterWaypointDistance(previousPoint, waypoint, config)
% enforceQuadcopterWaypointDistance - Удерживать расстояние между точками в пределах навигационных лимитов.
arguments
    previousPoint (3, 1) double
    waypoint (3, 1) double
    config (1, 1) struct
end

nav = config.quadcopter.navigation;
worldSize = config.world.size;

previousPoint = previousPoint(:);
waypoint = waypoint(:);
deltaXY = waypoint(1:2) - previousPoint(1:2);
distXY = norm(deltaXY);

if distXY < 1e-6
    angle = 2 * pi * rand();
    directionXY = [cos(angle); sin(angle)];
else
    directionXY = deltaXY / distXY;
end

targetDist = min(max(distXY, nav.minWaypointDistance), nav.maxWaypointDistance);
waypoint(1:2) = previousPoint(1:2) + directionXY * targetDist;

altRange = config.quadcopter.operatingAltitudeRange;
waypoint(3) = min(max(waypoint(3), altRange(1)), altRange(2));
waypoint = enforceWorldBounds(waypoint, worldSize);
waypoint(3) = min(max(waypoint(3), altRange(1)), altRange(2));

deltaXY = waypoint(1:2) - previousPoint(1:2);
distXY = norm(deltaXY);
if distXY > nav.maxWaypointDistance
    waypoint(1:2) = previousPoint(1:2) + deltaXY / distXY * nav.maxWaypointDistance;
    waypoint = enforceWorldBounds(waypoint, worldSize);
end
end
