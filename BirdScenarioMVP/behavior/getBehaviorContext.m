function context = getBehaviorContext(target, scenario, config)
% getBehaviorContext - Собрать контекст поведенческого решения для цели.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
end

context.Time = target.CurrentTime;
context.State = string(target.State);
context.Class = string(target.Class);
context.Subtype = string(target.Subtype);
context.Position = target.Position(:);
context.Speed = norm(target.Velocity);
context.Altitude = target.Position(3);
context.TimeInState = target.TimeInState;

if isfield(target, 'Behavior') && isfield(target.Behavior, 'CurrentGoal')
    context.CurrentGoal = string(target.Behavior.CurrentGoal);
else
    context.CurrentGoal = "";
end

context.DistanceToTarget = computeDistanceToTarget(target);
context.DistanceToHome = computeDistanceToHome(target);
context.HasTarget = ~isnan(context.DistanceToTarget) && context.DistanceToTarget > 0;
context.IsNearTarget = context.HasTarget && context.DistanceToTarget < 50;
context.IsLowAltitude = context.Altitude < 30;
context.IsHighAltitude = context.Altitude > 150;

if isfield(target, 'Behavior') && isfield(target.Behavior, 'Memory')
    context.RecentActions = target.Behavior.Memory.RecentActions;
else
    context.RecentActions = strings(0, 1);
end

context.MissionComplete = false;
if isfield(target, 'Payload') && isfield(target.Payload, 'MissionComplete')
    context.MissionComplete = logical(target.Payload.MissionComplete);
end

context.RoadDeviation = nan;
context.SpeedLimit = nan;
context.OnRoad = false;
if target.Class == "ground" && isfield(target, 'Payload')
    if isfield(target.Payload, 'RoadDeviation')
        context.RoadDeviation = target.Payload.RoadDeviation;
    end
    if isfield(target.Payload, 'SpeedLimit')
        context.SpeedLimit = target.Payload.SpeedLimit;
    end
    context.OnRoad = ~isnan(context.RoadDeviation) && context.RoadDeviation <= 10;
end
end

function dist = computeDistanceToTarget(target)
dist = nan;
if target.Class == "bird"
    if isfield(target.Payload, 'TargetTreePosition') && ~isempty(target.Payload.TargetTreePosition)
        dist = norm(target.Payload.TargetTreePosition(:) - target.Position);
    end
elseif target.Class == "air" && ismember(target.Subtype, ["quadcopter", "fixedWingUAV"])
    if isfield(target.Payload, 'CurrentWaypoint') && ~isempty(target.Payload.CurrentWaypoint)
        dist = norm(target.Payload.CurrentWaypoint(:) - target.Position);
    elseif isfield(target.Payload, 'DistanceToWaypoint') && ~isempty(target.Payload.DistanceToWaypoint)
        dist = target.Payload.DistanceToWaypoint;
    end
elseif target.Class == "ground" && target.Subtype == "vehicle"
    if isfield(target.Payload, 'CurrentWaypoint') && ~isempty(target.Payload.CurrentWaypoint)
        dist = norm(target.Payload.CurrentWaypoint(:) - target.Position);
    elseif isfield(target.Payload, 'DistanceToWaypoint') && ~isempty(target.Payload.DistanceToWaypoint)
        dist = target.Payload.DistanceToWaypoint;
    end
end
end

function dist = computeDistanceToHome(target)
dist = nan;
if target.Class == "air" && ismember(target.Subtype, ["quadcopter", "fixedWingUAV"])
    if isfield(target.Payload, 'HomePosition') && ~isempty(target.Payload.HomePosition)
        dist = norm(target.Payload.HomePosition(:) - target.Position);
    end
elseif target.Class == "ground" && target.Subtype == "vehicle"
    if isfield(target.Payload, 'HomePosition') && ~isempty(target.Payload.HomePosition)
        dist = norm(target.Payload.HomePosition(:) - target.Position);
    end
end
end
