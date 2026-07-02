function target = leaveRoadTemporarily(target, roadNetwork, config)
% leaveRoadTemporarily - Set a temporary off-road target 30-100 m from road.
arguments
    target (1, 1) struct
    roadNetwork (1, 1) struct %#ok<INUSD>
    config (1, 1) struct
end

gv = config.groundVehicle;
range = gv.offroadDistanceRange;
distance = range(1) + rand() * (range(2) - range(1));

if isfield(target.Payload, 'Route') && ~isempty(target.Payload.Route.Points)
    returnDistance = min(target.Payload.RouteProgress + max(40, 0.75 * distance), ...
        target.Payload.Route.Length);
    routePoint = getGroundRoutePoint(target.Payload.Route, returnDistance);
    heading = routePoint.Tangent(1:2);
    target.Payload.ReturnRouteDistance = returnDistance;
    target.Payload.ReturnRoadPoint = routePoint.Position(:);
else
    heading = target.Velocity(1:2);
end
if norm(heading) < 1e-6 && isfield(target.Payload, 'CurrentWaypoint')
    heading = target.Payload.CurrentWaypoint(1:2) - target.Position(1:2);
end
if norm(heading) < 1e-6
    heading = [1; 0];
end
heading = heading(:) / norm(heading);
side = [-heading(2); heading(1)];
if rand() < 0.5
    side = -side;
end

forward = 0.5 * distance * heading;
targetPoint = target.Position(:);
targetPoint(1:2) = targetPoint(1:2) + forward + distance * side;
targetPoint(3) = 0;
targetPoint = enforceWorldBounds(targetPoint, config.world.size);
targetPoint(3) = 0;

target.Payload.OffroadTarget = targetPoint(:);
target.Payload.OffRoadTarget = targetPoint(:);
target.Payload.OffroadDistance = distance;
target.Payload.LastDecision = "LeaveRoad";
target.Payload.GroundAction = "LeaveRoad";
target.Payload.IsOffRoad = true;
target.Payload.LastNavigationEvent = "leaveRoad";
end
