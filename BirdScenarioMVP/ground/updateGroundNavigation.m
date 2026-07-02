function target = updateGroundNavigation(target, scenario, config, dt)
% updateGroundNavigation - Update route progress and road deviation metrics.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double %#ok<INUSD>
end

if ~isfield(scenario, 'RoadNetwork') || isempty(scenario.RoadNetwork.Roads)
    return;
end

state = string(target.State);
if isfield(target.Payload, 'Route') && ~isempty(target.Payload.Route.Points)
    target = updateRouteProgress(target, config, dt);
else
    nearest = findNearestRoad(target.Position(:), scenario.RoadNetwork);
    target.Payload.NearestRoadPoint = nearest.Position(:);
    target.Payload.RoadDeviation = nearest.Distance;
    if state ~= "LeaveRoad"
        target.Payload.CurrentRoadID = nearest.RoadID;
        target.Payload.CurrentEdgeID = nearest.EdgeID;
        target.Payload.CurrentRoadIndex = nearest.RoadIndex;
        target.Payload.SpeedLimit = nearest.SpeedLimit;
    end
end

targetPoint = getNavigationTarget(target);
if isfield(target.Payload, 'WaypointRouteDistances') && ismember(state, ["Drive", "Turn", "Stop"])
    idx = min(target.Payload.CurrentWaypointIndex, numel(target.Payload.WaypointRouteDistances));
    target.Payload.DistanceToWaypoint = max(0, ...
        target.Payload.WaypointRouteDistances(idx) - target.Payload.RouteProgress);
else
    target.Payload.DistanceToWaypoint = norm(targetPoint(:) - target.Position(:));
end

switch state
    case "Drive"
        if target.Payload.DistanceToWaypoint <= target.Payload.WaypointArrivalRadius
            target = advanceGroundWaypoint(target, config);
        end
    case "Turn"
        if target.TimeInState >= 2
            target = transitionGroundState(target, "Drive", "turnComplete", config);
        end
    case "Stop"
        if target.CurrentTime >= target.Payload.StopUntilTime
            target = transitionGroundState(target, "Drive", "stopComplete", config);
        end
    case {"LeaveRoad", "OffRoad"}
        if ~isempty(target.Payload.OffroadTarget) && ...
                norm(target.Payload.OffroadTarget(:) - target.Position(:)) <= target.Payload.WaypointArrivalRadius
            target = returnToRoad(target, scenario.RoadNetwork);
            target = transitionGroundState(target, "ReturnRoad", "offroadComplete", config);
        end
    case "ReturnRoad"
        if isempty(target.Payload.ReturnRoadPoint)
            target = returnToRoad(target, scenario.RoadNetwork);
        end
        if norm(target.Payload.ReturnRoadPoint(:) - target.Position(:)) <= ...
                target.Payload.WaypointArrivalRadius || ...
                target.Payload.RoadDeviation <= config.groundVehicle.roadDeviationTolerance
            target.Position(3) = 0;
            if isfield(target.Payload, 'ReturnRouteDistance') && target.Payload.ReturnRouteDistance > 0
                target.Payload.RouteProgress = max(target.Payload.RouteProgress, target.Payload.ReturnRouteDistance);
                target.Payload.Route.CurrentDistance = target.Payload.RouteProgress;
            end
            target = transitionGroundState(target, "Drive", "roadReached", config);
        end
end
end

function target = updateRouteProgress(target, config, dt)
state = string(target.State);
minAlong = max(0, target.Payload.RouteProgress - config.groundVehicle.waypointArrivalRadius);
projection = projectGroundRoute(target.Position(:), target.Payload.Route, minAlong);
target.Payload.NearestRoadPoint = projection.Position(:);
target.Payload.RoadDeviation = projection.DistanceToRoute;
target.Payload.OnRoad = projection.DistanceToRoute <= config.groundVehicle.roadDeviationTolerance;
target.Payload.IsOffRoad = ~target.Payload.OnRoad || ismember(state, ["OffRoad", "LeaveRoad", "ReturnRoad"]);
target.Payload.CurrentRoadPoint = projection.Position(:);

if ismember(state, ["Drive", "Turn", "Stop"])
    target.Payload.RouteProgress = max(target.Payload.RouteProgress, projection.DistanceAlong);
    target.Payload.Route.CurrentDistance = target.Payload.RouteProgress;
    rp = getGroundRoutePoint(target.Payload.Route, target.Payload.RouteProgress);
    target.Payload.CurrentRoadID = rp.RoadID;
    target.Payload.CurrentEdgeID = rp.EdgeID;
    target.Payload.RouteRoadID = rp.RoadID;
    target.Payload.Route.CurrentSegmentIndex = rp.SegmentIndex;
    target.Payload.SpeedLimit = getRouteSpeedLimit(target.Payload.Route, rp, target.Payload.SpeedLimit);

    if state == "Drive" && projection.DistanceToRoute <= 3 * config.groundVehicle.roadDeviationTolerance
        maxCorrection = max(0.5, 0.25 * max(norm(target.Velocity(1:2)), config.groundVehicle.speedRange(1)) * dt);
        correction = projection.Position(:) - target.Position(:);
        correction(3) = 0;
        if norm(correction) > maxCorrection
            correction = correction * (maxCorrection / norm(correction));
        end
        target.Position = target.Position + correction;
        target.Position(3) = 0;
    end
end
end

function speedLimit = getRouteSpeedLimit(route, routePoint, defaultSpeedLimit)
speedLimit = defaultSpeedLimit;
if isfield(route, 'RoadSpeedLimits') && isfield(route, 'EdgeIDs')
    idx = find(route.EdgeIDs == routePoint.EdgeID, 1, 'first');
    if ~isempty(idx) && numel(route.RoadSpeedLimits) >= idx
        speedLimit = route.RoadSpeedLimits(idx);
    end
end
end

function point = getNavigationTarget(target)
switch string(target.State)
    case "LeaveRoad"
        point = target.Payload.OffroadTarget;
    case "ReturnRoad"
        point = target.Payload.ReturnRoadPoint;
    otherwise
        point = target.Payload.CurrentWaypoint;
end
if isempty(point)
    point = target.Payload.CurrentWaypoint;
end
end
