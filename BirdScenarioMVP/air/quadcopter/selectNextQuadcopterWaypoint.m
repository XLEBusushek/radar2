function quad = selectNextQuadcopterWaypoint(quad, config)
% selectNextQuadcopterWaypoint - Перейти к следующей точке маршрута или вернуться домой.
arguments
    quad (1, 1) struct
    config (1, 1) struct
end

idx = quad.Payload.CurrentWaypointIndex + 1;
numWaypoints = size(quad.Payload.Waypoints, 1);

if idx > numWaypoints
    if string(quad.State) ~= "Return"
        quad = transitionQuadcopterState(quad, "Return", "missionComplete", config);
    end
    return;
end

quad.Payload.CurrentWaypointIndex = idx;
quad.Payload.CurrentWaypoint = quad.Payload.Waypoints(idx, :).';
quad.Payload.DistanceToWaypoint = norm(quad.Payload.CurrentWaypoint(:) - quad.Position);
speedRange = config.quadcopter.transitSpeedRange;
quad.Payload.DesiredSpeed = speedRange(1) + rand() * (speedRange(2) - speedRange(1));
quad.Payload.DesiredAltitude = quad.Payload.CurrentWaypoint(3);
quad = resetQuadcopterNavigationFlags(quad);
quad.Payload.LastNavigationEvent = "nextWaypoint";
end
