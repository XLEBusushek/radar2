function [desiredVelocity, lookaheadPoint] = computeGroundDesiredVelocity(target, scenario, config)
% computeGroundDesiredVelocity - Compute ground desired velocity with pure pursuit.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
end

state = string(target.State);
if ismember(state, ["Idle", "Stop"])
    desiredVelocity = zeros(3, 1);
    lookaheadPoint = target.Position(:);
    return;
end

speed = clampDesiredSpeed(target, config);
if state == "LeaveRoad" || state == "OffRoad"
    aimPoint = target.Payload.OffroadTarget;
elseif state == "ReturnRoad"
    aimPoint = target.Payload.ReturnRoadPoint;
else
    [aimPoint, speedFactor] = purePursuitPoint(target, scenario, config);
    speed = speed * speedFactor;
end

if isempty(aimPoint)
    aimPoint = target.Payload.CurrentWaypoint;
end
lookaheadPoint = aimPoint(:);

direction = aimPoint(:) - target.Position(:);
direction(3) = 0;
if norm(direction) < 1e-6
    desiredVelocity = zeros(3, 1);
    return;
end

direction = direction / norm(direction);
desiredVelocity = speed * direction;
desiredVelocity(3) = 0;
end

function speed = clampDesiredSpeed(target, config)
gv = config.groundVehicle;
speed = target.Payload.DesiredSpeed;
if isempty(speed) || speed <= 0
    speed = gv.speedRange(1);
end
if isfield(target.Payload, 'SpeedLimit') && ~isnan(target.Payload.SpeedLimit)
    speed = min(speed, target.Payload.SpeedLimit);
end
speed = min(max(speed, gv.speedRange(1)), gv.speedRange(2));
if ismember(string(target.State), ["LeaveRoad", "ReturnRoad"])
    speed = max(gv.speedRange(1), speed * gv.offroadSpeedFactor);
end
end

function [point, speedFactor] = purePursuitPoint(target, scenario, config)
point = target.Payload.CurrentWaypoint;
speedFactor = 1.0;
if isfield(target.Payload, 'Route') && ~isempty(target.Payload.Route.Points)
    lookahead = target.Payload.LookaheadDistance;
    if isempty(lookahead) || lookahead <= 0
        lookahead = config.groundVehicle.lookaheadDistance;
    end
    lookaheadDistance = min(target.Payload.RouteProgress + lookahead, target.Payload.Route.Length);
    routePoint = getGroundRoutePoint(target.Payload.Route, lookaheadDistance);
    point = routePoint.Position(:);
    speedFactor = cornerSpeedFactor(target.Payload.Route, target.Payload.RouteProgress, lookahead);
    return;
end

if ~isfield(scenario, 'RoadNetwork') || isempty(scenario.RoadNetwork.Roads)
    return;
end

roadIdx = find([scenario.RoadNetwork.Roads.ID] == target.Payload.CurrentRoadID, 1, 'first');
if isempty(roadIdx)
    return;
end

road = scenario.RoadNetwork.Roads(roadIdx);
lookahead = target.Payload.LookaheadDistance;
if isempty(lookahead) || lookahead <= 0
    lookahead = config.groundVehicle.lookaheadDistance;
end

nearest = findNearestOnRoad(target.Position(:), road);
distanceTarget = nearest.DistanceAlong + lookahead;
point = pointAtDistance(road.Points, distanceTarget);
targetWaypoint = target.Payload.CurrentWaypoint(:);
if norm(targetWaypoint(1:2) - target.Position(1:2)) < lookahead
    point = targetWaypoint;
end
point(3) = 0;
end

function factor = cornerSpeedFactor(route, currentDistance, lookahead)
factor = 1.0;
if size(route.Points, 1) < 3
    return;
end

cumulative = route.CumulativeDistance(:);
startIdx = find(cumulative <= currentDistance, 1, 'last');
endIdx = find(cumulative <= min(currentDistance + 1.5 * lookahead, cumulative(end)), 1, 'last');
startIdx = min(max(startIdx, 1), size(route.Points, 1) - 2);
endIdx = min(max(endIdx, startIdx), size(route.Points, 1) - 2);

maxTurn = 0;
for i = startIdx:endIdx
    v1 = route.Points(i + 1, 1:2) - route.Points(i, 1:2);
    v2 = route.Points(i + 2, 1:2) - route.Points(i + 1, 1:2);
    if norm(v1) < 1e-6 || norm(v2) < 1e-6
        continue;
    end
    cosAngle = dot(v1, v2) / (norm(v1) * norm(v2));
    cosAngle = min(max(cosAngle, -1), 1);
    maxTurn = max(maxTurn, abs(acos(cosAngle)));
end

if maxTurn > deg2rad(45)
    factor = 0.55;
elseif maxTurn > deg2rad(25)
    factor = 0.75;
end
end

function nearest = findNearestOnRoad(position, road)
nearest.Distance = inf;
nearest.DistanceAlong = 0;
distanceAlongBase = 0;
pts = road.Points;
for i = 1:(size(pts, 1) - 1)
    [proj, frac] = projectToSegment(position(1:2).', pts(i, 1:2), pts(i + 1, 1:2));
    dist = norm(proj(:) - position(1:2));
    segLen = norm(pts(i + 1, 1:2) - pts(i, 1:2));
    if dist < nearest.Distance
        nearest.Distance = dist;
        nearest.DistanceAlong = distanceAlongBase + frac * segLen;
    end
    distanceAlongBase = distanceAlongBase + segLen;
end
end

function point = pointAtDistance(points, distanceAlong)
lengths = vecnorm(diff(points(:, 1:2), 1, 1), 2, 2);
total = sum(lengths);
if total <= 0
    point = points(1, :).';
    return;
end
distanceAlong = min(max(distanceAlong, 0), total);
remaining = distanceAlong;
for i = 1:numel(lengths)
    if remaining <= lengths(i)
        ratio = remaining / max(lengths(i), 1e-9);
        point = points(i, :) + ratio * (points(i + 1, :) - points(i, :));
        point = point(:);
        return;
    end
    remaining = remaining - lengths(i);
end
point = points(end, :).';
end

function [proj, frac] = projectToSegment(p, a, b)
ab = b - a;
den = dot(ab, ab);
if den <= 1e-9
    frac = 0;
else
    frac = dot(p - a, ab) / den;
end
frac = min(max(frac, 0), 1);
proj = a + frac * ab;
end
