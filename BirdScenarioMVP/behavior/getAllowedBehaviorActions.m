function actions = getAllowedBehaviorActions(target, context, config)
% getAllowedBehaviorActions - Return allowed behavior actions for current target.
arguments
    target (1, 1) struct
    context (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
end

if target.Class == "bird"
    actions = getBirdAllowedActions(target, context);
elseif target.Class == "air" && target.Subtype == "quadcopter"
    actions = getQuadcopterAllowedActions(target, context);
elseif target.Class == "air" && target.Subtype == "fixedWingUAV"
    actions = getFixedWingAllowedActions(target, context, config);
elseif target.Class == "ground" && target.Subtype == "vehicle"
    actions = getGroundAllowedActions(target, context);
else
    actions = strings(0, 1);
end
end

function actions = getBirdAllowedActions(target, context)
state = string(context.State);
actions = strings(0, 1);

switch state
    case "Perched"
        actions = ["stay", "takeoff"];
    case "Takeoff"
        actions = ["continueFlight"];
    case "Cruise"
        actions = ["continueFlight", "retargetTree", "flyBy", "startLanding", ...
            "sharpManeuver", "changeAltitude"];
        if context.IsNearTarget
            actions(end + 1) = "startLanding";
        end
    case "Landing"
        actions = ["continueFlight"];
    case "Hidden"
        actions = ["hide", "perch"];
    otherwise
        actions = "stay";
end

actions = unique(actions, 'stable');
end

function actions = getGroundAllowedActions(target, context)
state = string(context.State);
actions = strings(0, 1);

switch state
    case "Idle"
        actions = ["Wait", "ContinueDrive"];
    case "Drive"
        actions = ["ContinueDrive", "Stop", "ChangeSpeed", "LeaveRoad", "TurnAround", "Wait"];
        if context.IsNearTarget
            actions(end + 1) = "ContinueDrive";
        end
    case "Stop"
        actions = ["Wait", "ContinueDrive"];
    case "Turn"
        actions = ["ContinueDrive", "Wait"];
    case "LeaveRoad"
        actions = ["ContinueDrive", "ReturnRoad"];
    case "ReturnRoad"
        actions = ["ReturnRoad", "ContinueDrive"];
    otherwise
        actions = "Wait";
end

if isfield(target.Payload, 'RoadDeviation') && target.Payload.RoadDeviation > 20
    actions(actions == "LeaveRoad") = [];
end
if state == "ReturnRoad"
    actions(actions == "LeaveRoad") = [];
end

actions = unique(actions, 'stable');
end

function actions = getFixedWingAllowedActions(target, context, config)
state = string(context.State);
actions = strings(0, 1);
nearBoundary = isfield(target.Payload, 'NearBoundary') && target.Payload.NearBoundary;
nearWaypointZone = isFixedWingNearWaypointManeuverZone(target, config);
allowExitArea = isfield(config, 'fixedWing') && isfield(config.fixedWing, 'allowExitArea') && ...
    config.fixedWing.allowExitArea;

switch state
    case "Cruise"
        if nearWaypointZone
            actions = "ContinueCruise";
        else
            actions = ["ContinueCruise", "ChangeAltitude", "StartTurn"];
            if ~nearBoundary
                arrivalRadius = target.Payload.WaypointArrivalRadius;
                if isfield(config.fixedWing, 'navigation') && ...
                        isfield(config.fixedWing.navigation, 'arrivalRadius')
                    arrivalRadius = config.fixedWing.navigation.arrivalRadius;
                end
                nearWaypoint = computeFixedWingWaypointDistance(target) <= arrivalRadius * 1.25;
                if nearWaypoint
                    actions(end + 1) = "StartLoiter";
                end
                if isfield(config.fixedWing, 'diveProbability') && config.fixedWing.diveProbability > 0
                    actions(end + 1) = "StartDive";
                end
            end
        end
        if target.Payload.MissionComplete
            actions(end + 1) = "ReturnHome";
        end
        if allowExitArea
            actions(end + 1) = "ExitArea";
        end
    case "Turn"
        actions = ["ContinueCruise", "ChangeAltitude"];
        if target.Payload.MissionComplete
            actions(end + 1) = "ReturnHome";
        end
    case {"Climb", "Descend"}
        actions = ["ContinueCruise", "StartTurn"];
        if target.Payload.MissionComplete
            actions(end + 1) = "ReturnHome";
        end
    case "Loiter"
        actions = "ContinueCruise";
        if target.Payload.MissionComplete
            actions(end + 1) = "ReturnHome";
        end
        if ~nearBoundary && isfield(config.fixedWing, 'diveProbability') && ...
                config.fixedWing.diveProbability > 0
            actions(end + 1) = "StartDive";
        end
    case "Dive"
        actions = "RecoverFromDive";
    case "Recover"
        actions = ["RecoverFromDive", "ContinueCruise"];
        if target.Payload.MissionComplete
            actions(end + 1) = "ReturnHome";
        end
    case "Return"
        actions = strings(0, 1);
        if target.Payload.MissionComplete
            actions = "ReturnHome";
        end
        if allowExitArea
            actions(end + 1) = "ExitArea";
        end
    case "ExitArea"
        actions = "ExitArea";
    otherwise
        actions = "ContinueCruise";
end

if ismember("StartDive", actions) && target.Position(3) < 120
    actions(actions == "StartDive") = [];
end

actions = unique(actions, 'stable');
end

function actions = getQuadcopterAllowedActions(target, context)
state = string(context.State);
actions = strings(0, 1);

if isfield(target.Payload, 'ForceDirectToWaypoint') && target.Payload.ForceDirectToWaypoint
    if state == "Return"
        actions = ["returnHome", "land"];
    elseif state == "Landing"
        actions = "land";
    else
        actions = "continueTransit";
    end
    actions = unique(actions, 'stable');
    return;
end

switch state
    case "Idle"
        if isfield(target.Payload, 'MissionComplete') && target.Payload.MissionComplete
            actions = "wait";
        else
            actions = ["wait", "takeoff"];
        end
    case "Takeoff"
        actions = ["continueTransit", "changeAltitude"];
    case "Transit"
        actions = ["continueTransit", "hover", "scan", "changeAltitude", ...
            "nextWaypoint", "slowDown", "speedUp"];
        if context.IsNearTarget
            actions(end + 1) = "nextWaypoint";
        end
    case "Hover"
        actions = ["hover", "scan", "continueTransit", "changeAltitude", "returnHome"];
    case "Scan"
        actions = ["scan", "continueTransit", "changeAltitude"];
    case "Return"
        actions = ["returnHome", "land", "slowDown", "changeAltitude"];
    case "Landing"
        actions = ["land", "slowDown"];
    otherwise
        actions = "wait";
end

if isfield(target.Payload, 'ConsecutiveHoverCount') && ...
        isfield(target.Payload, 'ConsecutiveScanCount')
    if target.Payload.ConsecutiveHoverCount >= 1
        actions(actions == "hover") = [];
    end
    if target.Payload.ConsecutiveScanCount >= 1
        actions(actions == "scan") = [];
    end
end

if ismember(state, ["Hover", "Scan"]) && isfield(target.Payload, 'CurrentWaypoint')
    actions = ["continueTransit", "returnHome"];
end

actions = unique(actions, 'stable');
end
