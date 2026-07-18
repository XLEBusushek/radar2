function distance = computeFixedWingWaypointDistance(target)
% computeFixedWingWaypointDistance - Горизонтальное расстояние до активной точки.
arguments
    target (1, 1) struct
end

delta = target.Payload.CurrentWaypoint(:) - target.Position(:);
distance = norm(delta(1:2));
end
