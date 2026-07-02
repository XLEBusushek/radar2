function weights = evaluateBehaviorWeights(target, context, actions, config)
% evaluateBehaviorWeights - Compute action weights from context and personality.
arguments
    target (1, 1) struct
    context (1, 1) struct
    actions (:, 1) string
    config (1, 1) struct
end

numActions = numel(actions);
weights.ActionNames = actions(:);
weights.Values = zeros(numActions, 1);
weights.Reasons = strings(numActions, 1);

if numActions == 0
    return;
end

p = target.Behavior.Personality;
memory = target.Behavior.Memory;

for i = 1:numActions
    action = actions(i);
    [value, reason] = baseWeightForAction(target, context, action, p, config);
    value = value * personalityMultiplier(action, p);
    value = value * recentActionPenalty(action, memory);
    value = value * cooldownPenalty(action, memory, context.Time);

    weights.Values(i) = max(value, 0);
    weights.Reasons(i) = reason;
end
end

function [value, reason] = baseWeightForAction(target, context, action, p, config)
action = string(action);
value = 1;
reason = "base";

if target.Class == "bird"
    [value, reason] = birdBaseWeight(context, action, p, config);
elseif target.Class == "air" && target.Subtype == "fixedWingUAV"
    [value, reason] = fixedWingBaseWeight(target, context, action, p, config);
elseif target.Class == "ground" && target.Subtype == "vehicle"
    [value, reason] = groundBaseWeight(target, context, action, p, config);
else
    [value, reason] = quadcopterBaseWeight(target, context, action, p, config);
end
end

function [value, reason] = birdBaseWeight(context, action, p, config)
state = string(context.State);
value = 5;
reason = "base";

switch action
    case "stay"
        if state == "Perched" || state == "Hidden"
            value = 40 * p.Caution;
            reason = "caution";
        else
            value = 10;
        end
    case "takeoff"
        value = 10 + context.TimeInState * 8 * p.MissionFocus;
        reason = "missionTime";
    case "continueFlight"
        if state == "Cruise" || state == "Takeoff"
            value = 60 * p.MissionFocus;
            reason = "mission";
        else
            value = 20;
        end
    case "retargetTree"
        value = 15 * p.Curiosity;
        reason = "curiosity";
    case "flyBy"
        value = 12 * p.Randomness;
        reason = "randomness";
    case "startLanding"
        if context.IsNearTarget
            value = 80;
            reason = "nearTarget";
        else
            value = 5 + max(0, 30 - context.DistanceToTarget / 20);
            reason = "approach";
        end
    case "hide"
        value = 25 * p.Caution;
        reason = "caution";
    case "perch"
        value = 20 + context.TimeInState * 5;
        reason = "rest";
    case "sharpManeuver"
        value = 10 * p.ManeuverBias * p.Randomness;
        reason = "maneuver";
    case "changeAltitude"
        value = 8 * p.AltitudeBias;
        reason = "altitude";
    otherwise
        value = 1;
end

if isfield(config, 'birds') && isfield(config.birds, 'landing') && config.birds.landing.enabled
    if action == "startLanding" && state == "Cruise" && ~context.IsNearTarget
        value = value * 0.3;
    end
end
end

function [value, reason] = groundBaseWeight(target, context, action, p, config)
state = string(context.State);
value = 5;
reason = "base";

switch action
    case "ContinueDrive"
        if ismember(state, ["Drive", "Turn", "ReturnRoad"])
            value = 80 * p.Attention;
            reason = "roadFollowing";
        elseif state == "Idle"
            value = 25 + context.TimeInState * 6 * p.PatrolProbability;
            reason = "patrolStart";
        elseif state == "Stop"
            value = 15 + max(0, context.TimeInState - 2) * 8;
            reason = "stopComplete";
        else
            value = 50;
            reason = "continue";
        end
    case "Stop"
        value = 5 * p.StopProbability * max(0.5, 1.5 - p.DriverAggression);
        if state == "Drive"
            value = value + min(context.TimeInState, 20) * 0.25;
        end
        reason = "stopTendency";
    case "ChangeSpeed"
        value = 6 * p.SpeedBias * p.DriverAggression;
        reason = "speedBias";
    case "LeaveRoad"
        value = 4 * p.LeaveRoadProbability * p.Curiosity * max(0.2, 1.6 - p.RoadDiscipline);
        if ~context.OnRoad
            value = 0;
            reason = "offroadBlocked";
        else
            reason = "roadDiscipline";
        end
    case "ReturnRoad"
        value = 80;
        if ~isnan(context.RoadDeviation)
            value = value + min(context.RoadDeviation, 100);
        end
        reason = "returnToRoad";
    case "TurnAround"
        value = 4 * p.Randomness * p.PatrolProbability;
        if isfield(target.Payload, 'CurrentWaypointIndex') && ...
                target.Payload.CurrentWaypointIndex >= size(target.Payload.Waypoints, 1)
            value = value + 30;
        end
        reason = "patrol";
    case "Wait"
        if state == "Stop" || state == "Idle"
            value = 30 * p.Caution;
        else
            value = 3 * p.Caution;
        end
        reason = "caution";
    otherwise
        value = 1;
end

if isfield(config, 'groundVehicle') && isfield(target.Payload, 'RoadDeviation') && ...
        target.Payload.RoadDeviation > config.groundVehicle.roadDeviationTolerance && ...
        action == "ReturnRoad"
    value = value * 1.5;
end
if ismember(action, ["Stop", "LeaveRoad"]) && isfield(target.Payload, 'RouteProgress')
    if target.Payload.RouteProgress < 150 || isGroundNearRouteCorner(target)
        value = value * 0.25;
        reason = "routeSafety";
    end
end
end

function nearCorner = isGroundNearRouteCorner(target)
nearCorner = false;
if ~isfield(target.Payload, 'Route') || size(target.Payload.Route.Points, 1) < 3
    return;
end
route = target.Payload.Route;
lookahead = 120;
currentDistance = target.Payload.RouteProgress;
cumulative = route.CumulativeDistance(:);
startIdx = find(cumulative <= currentDistance, 1, 'last');
endIdx = find(cumulative <= min(currentDistance + lookahead, cumulative(end)), 1, 'last');
maxCornerIdx = size(route.Points, 1) - 2;
startIdx = min(max(startIdx, 1), maxCornerIdx);
endIdx = min(max(endIdx, startIdx), maxCornerIdx);
for i = startIdx:endIdx
    v1 = route.Points(i + 1, 1:2) - route.Points(i, 1:2);
    v2 = route.Points(i + 2, 1:2) - route.Points(i + 1, 1:2);
    if norm(v1) < 1e-6 || norm(v2) < 1e-6
        continue;
    end
    angle = acos(min(max(dot(v1, v2) / (norm(v1) * norm(v2)), -1), 1));
    if abs(angle) > deg2rad(35)
        nearCorner = true;
        return;
    end
end
end

function [value, reason] = quadcopterBaseWeight(target, context, action, p, config)
state = string(context.State);
value = 5;
reason = "base";
qc = config.quadcopter;
if isfield(target.Payload, 'ForceDirectToWaypoint') && target.Payload.ForceDirectToWaypoint
    if action == "continueTransit"
        value = 120;
        reason = "forceDirect";
    elseif action == "returnHome" && state == "Return"
        value = 100;
        reason = "returnHome";
    elseif action == "returnHome"
        value = 5;
        reason = "forceDirectTransit";
    else
        value = 0;
        reason = "forceDirectBlocked";
    end
    return;
end

switch action
    case "wait"
        value = 30 * p.Caution;
        reason = "caution";
    case "takeoff"
        value = 15 + context.TimeInState * 10;
        reason = "missionTime";
    case "continueTransit"
        if state == "Transit" || state == "Takeoff"
            value = 90 * p.MissionFocus;
            reason = "mission";
        else
            value = 50;
        end
        if isfield(target.Payload, 'NoProgressTime')
            value = value + min(target.Payload.NoProgressTime * 5, 60);
        end
    case "hover"
        value = 6 * p.HoverBias;
        if state == "Transit"
            value = value + min(context.TimeInState, 10) * 0.5;
        end
        reason = "hoverBias";
    case "scan"
        value = 8 * p.Curiosity * p.ScanBias;
        reason = "curiosity";
    case "changeAltitude"
        value = 10 * p.AltitudeBias;
        reason = "altitude";
    case "nextWaypoint"
        if context.IsNearTarget
            value = 70;
            reason = "waypointReached";
        else
            value = 1;
        end
    case "returnHome"
        missionTime = target.CurrentTime;
        value = 8 + missionTime * 0.02 * p.ReturnBias;
        if isfield(target.Payload, 'CurrentWaypointIndex') && ...
                isfield(target.Payload, 'Waypoints')
            if target.Payload.CurrentWaypointIndex >= size(target.Payload.Waypoints, 1)
                value = value + 40;
            end
        end
        reason = "missionTime";
    case "land"
        if state == "Landing"
            value = 50 + p.MissionFocus * 10;
            reason = "landing";
        elseif state == "Return" && ~isnan(context.DistanceToHome) && ...
                context.DistanceToHome < qc.waypointArrivalRadius + 5
            value = 60 + p.MissionFocus * 10;
            if ~isnan(context.DistanceToHome) && context.DistanceToHome < qc.waypointArrivalRadius + 5
                value = value + 40;
            end
            reason = "nearHome";
        else
            value = 1;
        end
    case "slowDown"
        value = 12 * p.Caution;
        reason = "caution";
    case "speedUp"
        value = 12 * p.SpeedBias;
        reason = "speed";
    otherwise
        value = 1;
end
end

function [value, reason] = fixedWingBaseWeight(target, context, action, p, config)
state = string(context.State);
value = 5;
reason = "base";
fw = config.fixedWing;

switch action
    case "ContinueCruise"
        value = 95 * p.MissionFocus;
        if isfield(target.Payload, 'DistanceToWaypoint') && ...
                target.Payload.DistanceToWaypoint < target.Payload.WaypointArrivalRadius
            value = value + 25;
            reason = "waypoint";
        else
            reason = "mission";
        end
    case "ChangeAltitude"
        value = 10 * p.AltitudeBias;
        if context.Altitude < fw.operatingAltitudeRange(1) + 40 || ...
                context.Altitude > fw.operatingAltitudeRange(2) - 40
            value = value + 30;
        end
        reason = "altitude";
    case "StartTurn"
        headingError = 0;
        if isfield(target.Payload, 'TargetHeading') && isfield(target.Payload, 'CurrentHeading')
            headingError = abs(wrapToPiLocal(target.Payload.TargetHeading - target.Payload.CurrentHeading));
        end
        value = 8 + rad2deg(headingError);
        reason = "heading";
    case "StartLoiter"
        value = 5 * p.Curiosity * p.ManeuverBias;
        if state == "Cruise"
            value = value + min(context.TimeInState, 30) * 0.2;
        end
        reason = "loiterInterest";
    case "StartDive"
        value = 2 * p.ManeuverBias * p.Randomness;
        if context.Altitude > fw.operatingAltitudeRange(1) + 80
            value = value + fw.diveProbability * 100;
        else
            value = 0;
        end
        reason = "diveInterest";
    case "RecoverFromDive"
        value = 100;
        reason = "mandatoryRecover";
    case "ReturnHome"
        value = 6 + target.CurrentTime * fw.returnProbability * 2 * p.ReturnBias;
        if isfield(target.Payload, 'MissionComplete') && target.Payload.MissionComplete
            value = value + 50;
        end
        reason = "return";
    case "ExitArea"
        if state == "Return" || state == "ExitArea"
            value = 70;
        else
            value = 2;
        end
        reason = "exit";
    otherwise
        value = 1;
end
end

function mult = personalityMultiplier(action, p)
mult = 1.0;
switch string(action)
    case {"retargetTree", "flyBy"}
        mult = p.Randomness;
    case "scan"
        mult = p.ScanBias;
    case "hover"
        mult = p.HoverBias;
    case "returnHome"
        mult = p.ReturnBias;
    case {"speedUp", "continueTransit"}
        mult = p.SpeedBias;
    case {"ChangeSpeed", "ContinueDrive"}
        mult = p.SpeedBias;
    case {"ContinueCruise", "StartTurn"}
        mult = p.MissionFocus;
    case "StartLoiter"
        mult = p.Curiosity;
    case "StartDive"
        mult = p.ManeuverBias;
    case "ReturnHome"
        mult = p.ReturnBias;
    case "LeaveRoad"
        mult = p.LeaveRoadProbability;
    case "Stop"
        mult = p.StopProbability;
end
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end

function penalty = recentActionPenalty(action, memory)
penalty = 1.0;
if ~isfield(memory, 'RecentActions') || isempty(memory.RecentActions)
    return;
end
recent = memory.RecentActions;
count = sum(recent == string(action));
penalty = max(0.2, 1.0 - 0.15 * count);
end

function penalty = cooldownPenalty(action, memory, currentTime)
penalty = 1.0;
if ~isfield(memory, 'Cooldowns')
    return;
end
fieldName = matlab.lang.makeValidName(char(action));
if isfield(memory.Cooldowns, fieldName)
    if currentTime < memory.Cooldowns.(fieldName)
        penalty = 0;
    end
end
end
