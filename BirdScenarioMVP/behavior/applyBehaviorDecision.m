function target = applyBehaviorDecision(target, action, reason, scenario, config)
% applyBehaviorDecision - Сопоставить действие поведения с изменениями FSM / Payload.
arguments
    target (1, 1) struct
    action (1, 1) string
    reason (1, 1) string
    scenario (1, 1) struct
    config (1, 1) struct
end

action = string(action);
target.Behavior.LastDecision = action;

if target.Class == "bird"
    target = applyBirdBehaviorDecision(target, action, reason, scenario, config);
elseif target.Class == "air" && target.Subtype == "quadcopter"
    target = applyQuadcopterBehaviorDecision(target, action, reason, scenario, config);
elseif target.Class == "air" && target.Subtype == "fixedWingUAV"
    target = applyFixedWingBehaviorDecision(target, action, reason, scenario, config);
elseif target.Class == "ground" && target.Subtype == "vehicle"
    target = applyGroundBehaviorDecision(target, action, reason, scenario, config);
end

target = syncBehaviorGoalFromState(target);
end

function target = applyGroundBehaviorDecision(target, action, reason, scenario, config)
target.Payload.LastDecision = action;
switch action
    case "ContinueDrive"
        if ismember(string(target.State), ["Idle", "Stop", "Turn"])
            target = transitionGroundState(target, "Drive", "behavior:" + reason, config);
        elseif string(target.State) == "ReturnRoad" && ...
                target.Payload.RoadDeviation <= config.groundVehicle.roadDeviationTolerance
            target = transitionGroundState(target, "Drive", "behavior:" + reason, config);
        end
    case "Stop"
        if ismember(string(target.State), ["Drive", "Turn"])
            target = transitionGroundState(target, "Stop", "behavior:" + reason, config);
        end
    case "ChangeSpeed"
        target = adjustGroundDesiredSpeed(target, config);
    case "LeaveRoad"
        if string(target.State) == "Drive" && isfield(scenario, 'RoadNetwork')
            target = leaveRoadTemporarily(target, scenario.RoadNetwork, config);
            target = transitionGroundState(target, "LeaveRoad", "behavior:" + reason, config);
        end
    case "ReturnRoad"
        if ismember(string(target.State), ["LeaveRoad", "ReturnRoad"]) && ...
                isfield(scenario, 'RoadNetwork')
            target = returnToRoad(target, scenario.RoadNetwork);
            if string(target.State) == "LeaveRoad"
                target = transitionGroundState(target, "ReturnRoad", "behavior:" + reason, config);
            end
        end
    case "TurnAround"
        if string(target.State) == "Drive"
            target = reverseGroundBehaviorRoute(target);
            target = transitionGroundState(target, "Turn", "behavior:" + reason, config);
        end
    case "Wait"
        if string(target.State) == "Drive"
            target.Payload.DesiredSpeed = max(config.groundVehicle.speedRange(1), ...
                target.Payload.DesiredSpeed * 0.9);
        end
    otherwise
        % Неизвестное действие игнорируется.
end
end

function target = applyBirdBehaviorDecision(target, action, reason, scenario, config)
switch action
    case "stay"
        % без перехода
    case "takeoff"
        if string(target.State) == "Perched"
            target = transitionBirdState(target, "Takeoff", scenario, config, "behavior:" + reason);
        end
    case "continueFlight"
        if string(target.State) == "Takeoff"
            % обязательный переход обрабатывает Takeoff->Cruise
        end
    case "retargetTree"
        target = executeBirdRetarget(target, scenario, config);
    case "flyBy"
        target = executeBirdFlyBy(target, scenario, config);
    case "startLanding"
        if string(target.State) == "Cruise"
            target = transitionBirdState(target, "Landing", scenario, config, "behavior:" + reason);
        end
    case "hide"
        if string(target.State) == "Hidden"
            % остаться скрытым
        end
    case "perch"
        if string(target.State) == "Hidden"
            target = transitionBirdState(target, "Perched", scenario, config, "behavior:" + reason);
        end
    case "sharpManeuver"
        target = executeBirdSharpManeuver(target, config);
    case "changeAltitude"
        target = adjustBirdDesiredAltitude(target, config);
    otherwise
        % неизвестное действие игнорируется
end
end

function target = applyQuadcopterBehaviorDecision(target, action, reason, scenario, config)
if isfield(target.Payload, 'ForceDirectToWaypoint') && target.Payload.ForceDirectToWaypoint && ...
        ~ismember(action, ["continueTransit", "returnHome", "land"])
    target.Payload.LastNavigationEvent = "forceDirectBlocked";
    return;
end

switch action
    case "wait"
        % остаться в простое
    case "takeoff"
        if string(target.State) == "Idle"
            target = transitionQuadcopterState(target, "Takeoff", "behavior:" + reason, config);
        end
    case "continueTransit"
        state = string(target.State);
        if state == "Hover" || state == "Scan"
            target = transitionQuadcopterState(target, "Transit", "behavior:" + reason, config);
        end
    case "hover"
        if string(target.State) == "Transit" && ~target.Payload.ForceDirectToWaypoint
            target = transitionQuadcopterState(target, "Hover", "behavior:" + reason, config);
        end
    case "scan"
        if ismember(string(target.State), ["Transit", "Hover"]) && ...
                ~target.Payload.ForceDirectToWaypoint
            target = transitionQuadcopterState(target, "Scan", "behavior:" + reason, config);
        end
    case "changeAltitude"
        if ~target.Payload.ForceDirectToWaypoint
            target = adjustQuadcopterDesiredAltitude(target, config);
        end
    case "nextWaypoint"
        if string(target.State) == "Transit" && ...
                target.Payload.DistanceToWaypoint <= target.Payload.WaypointArrivalRadius
            target = advanceQuadcopterWaypoint(target, config);
            target.Payload.LastTransitionReason = "behavior:nextWaypoint";
        end
    case "returnHome"
        if ismember(string(target.State), ["Transit", "Hover", "Scan"])
            target = transitionQuadcopterState(target, "Return", "behavior:" + reason, config);
        end
    case "land"
        if string(target.State) == "Return" && isQuadcopterNearHome(target, config)
            target = transitionQuadcopterState(target, "Landing", "behavior:" + reason, config);
        end
    case "slowDown"
        target = scaleQuadcopterDesiredSpeed(target, 0.75);
    case "speedUp"
        target = scaleQuadcopterDesiredSpeed(target, 1.25);
    otherwise
        % неизвестное действие игнорируется
end
end

function target = applyFixedWingBehaviorDecision(target, action, reason, scenario, config) %#ok<INUSD>
target.Payload.LastDecision = action;
state = string(target.State);
switch action
    case "ContinueCruise"
        if ismember(state, ["Turn", "Climb", "Descend", "Loiter", "Recover"])
            target = transitionFixedWingState(target, "Cruise", "behavior:" + reason, config);
        elseif state == "Cruise" && target.Payload.DistanceToWaypoint <= target.Payload.WaypointArrivalRadius
            target = advanceFixedWingWaypoint(target, config);
        end
    case "ChangeAltitude"
        target = adjustFixedWingDesiredAltitude(target, config);
        if target.Payload.DesiredAltitude > target.Position(3)
            target = transitionFixedWingState(target, "Climb", "behavior:" + reason, config);
        else
            target = transitionFixedWingState(target, "Descend", "behavior:" + reason, config);
        end
    case "StartTurn"
        if ismember(state, ["Cruise", "Climb", "Descend"])
            target = transitionFixedWingState(target, "Turn", "behavior:" + reason, config);
        end
    case "StartLoiter"
        if ~isfield(target.Payload, 'NearBoundary') || ~target.Payload.NearBoundary
            if ismember(state, ["Cruise", "Turn"])
                target = transitionFixedWingState(target, "Loiter", "behavior:" + reason, config);
            end
        end
    case "StartDive"
        if ~isfield(target.Payload, 'NearBoundary') || ~target.Payload.NearBoundary
            if ismember(state, ["Cruise", "Loiter", "Descend"])
                target = transitionFixedWingState(target, "Dive", "behavior:" + reason, config);
            end
        end
    case "RecoverFromDive"
        if state == "Dive"
            target = transitionFixedWingState(target, "Recover", "behavior:" + reason, config);
        end
    case "ReturnHome"
        if ~ismember(state, ["Return", "ExitArea", "Dive"])
            target = transitionFixedWingState(target, "Return", "behavior:" + reason, config);
        end
    case "ExitArea"
        if state ~= "Dive" && isfield(config, 'fixedWing') && ...
                isfield(config.fixedWing, 'allowExitArea') && config.fixedWing.allowExitArea
            target = transitionFixedWingState(target, "ExitArea", "behavior:" + reason, config);
        end
    otherwise
        % Неизвестное действие игнорируется.
end
end

function nearHome = isQuadcopterNearHome(target, config)
home = target.Payload.HomePosition(:);
delta = home - target.Position(:);
nearHome = norm(delta(1:2)) <= target.Payload.WaypointArrivalRadius && ...
    abs(delta(3)) <= config.quadcopter.navigation.altitudeTargetTolerance + 5;
end

function target = executeBirdRetarget(target, scenario, config)
if string(target.State) ~= "Cruise" || isempty(target.Payload.TargetTreeID)
    return;
end
trees = scenario.Trees;
oldTargetID = target.Payload.TargetTreeID;
currentTreeID = target.Payload.CurrentTreeID;
newTargetID = selectAlternateTreeForBehavior(target, trees, config, oldTargetID, currentTreeID);
if isempty(newTargetID)
    return;
end
target.Payload.TargetTreeID = newTargetID;
target = reinitializeBirdCruiseTarget(target, scenario, config);
target.Payload.RetargetCount = target.Payload.RetargetCount + 1;
target.Payload.LastRealismEvent = "retarget";
target.Payload.SequentialFlyByCount = 0;
end

function target = executeBirdFlyBy(target, scenario, config)
if string(target.State) ~= "Cruise" || isempty(target.Payload.TargetTreeID)
    return;
end
trees = scenario.Trees;
oldTargetID = target.Payload.TargetTreeID;
currentTreeID = target.Payload.CurrentTreeID;
newTargetID = selectAlternateTreeForBehavior(target, trees, config, oldTargetID, currentTreeID);
if isempty(newTargetID)
    return;
end
target.Payload.TargetTreeID = newTargetID;
target = reinitializeBirdCruiseTarget(target, scenario, config);
target.Payload.FlyByCount = target.Payload.FlyByCount + 1;
flyByCount = 0;
if isfield(target.Payload, 'SequentialFlyByCount')
    flyByCount = target.Payload.SequentialFlyByCount;
end
target.Payload.SequentialFlyByCount = flyByCount + 1;
target.Payload.LastRealismEvent = "flyBy";
target.Payload.BlockLandingThisStep = true;
end

function target = executeBirdSharpManeuver(target, config)
if string(target.State) ~= "Cruise" || target.Payload.IsSharpManeuverActive
    return;
end
if ~isfield(config, 'birds') || ~isfield(config.birds, 'realism')
    return;
end
realism = config.birds.realism;
baseDir = target.Payload.FlightDirection(:);
if norm(baseDir) < 1e-6
    if ~isempty(target.Payload.TargetTreePosition)
        baseDir = target.Payload.TargetTreePosition(:) - target.Position(:);
        baseDir(3) = 0;
    end
    if norm(baseDir) < 1e-6
        baseDir = [1; 0; 0];
    end
    baseDir = baseDir / norm(baseDir);
end
angleDeg = mean(realism.sharpManeuverAngleRangeDeg);
angleRad = deg2rad(angleDeg);
sideDir = computePerpendicular2D(baseDir);
maneuverDir = cos(angleRad) * baseDir + sin(angleRad) * sideDir;
maneuverDir(3) = maneuverDir(3) * 0.2;
if norm(maneuverDir) > 0
    maneuverDir = maneuverDir / norm(maneuverDir);
end
duration = mean(realism.sharpManeuverDurationRange);
target.Payload.IsSharpManeuverActive = true;
target.Payload.SharpManeuverEndTime = target.CurrentTime + duration;
target.Payload.SharpManeuverDirection = maneuverDir(:);
target.Payload.LastRealismEvent = "sharpManeuver";
end

function target = adjustBirdDesiredAltitude(target, config)
worldZMax = config.world.size(3);
bias = target.Behavior.Personality.AltitudeBias;
delta = 8 * (bias - 1) + 5;
if bias >= 1
    target.Payload.DesiredAltitude = min(target.Position(3) + delta, worldZMax);
else
    target.Payload.DesiredAltitude = max(target.Position(3) - delta, 5);
end
end

function target = adjustQuadcopterDesiredAltitude(target, config)
qc = config.quadcopter;
bias = target.Behavior.Personality.AltitudeBias;
delta = 15 * (bias - 1) + 10;
if bias >= 1
    target.Payload.DesiredAltitude = min(target.Position(3) + delta, qc.operatingAltitudeRange(2));
else
    target.Payload.DesiredAltitude = max(target.Position(3) - delta, qc.operatingAltitudeRange(1));
end
end

function target = scaleQuadcopterDesiredSpeed(target, factor)
if ~isfield(target.Payload, 'DesiredSpeed') || isempty(target.Payload.DesiredSpeed)
    target.Payload.DesiredSpeed = 5;
end
target.Payload.DesiredSpeed = max(target.Payload.DesiredSpeed * factor, 0.5);
end

function target = adjustFixedWingDesiredAltitude(target, config)
fw = config.fixedWing;
bias = target.Behavior.Personality.AltitudeBias;
delta = 40 * (bias - 1) + 30;
if bias >= 1
    target.Payload.DesiredAltitude = min(target.Position(3) + delta, fw.operatingAltitudeRange(2));
else
    target.Payload.DesiredAltitude = max(target.Position(3) - abs(delta), fw.operatingAltitudeRange(1));
end
end

function target = adjustGroundDesiredSpeed(target, config)
if ~isfield(target.Payload, 'DesiredSpeed') || isempty(target.Payload.DesiredSpeed)
    target.Payload.DesiredSpeed = mean(config.groundVehicle.speedRange);
end
bias = target.Behavior.Personality.SpeedBias * target.Behavior.Personality.DriverAggression;
factor = 0.85 + 0.3 * min(max(bias - 0.5, 0), 1);
target.Payload.DesiredSpeed = target.Payload.DesiredSpeed * factor;
target.Payload.DesiredSpeed = min(max(target.Payload.DesiredSpeed, ...
    config.groundVehicle.speedRange(1)), config.groundVehicle.speedRange(2));
if isfield(target.Payload, 'SpeedLimit') && ~isnan(target.Payload.SpeedLimit)
    target.Payload.DesiredSpeed = min(target.Payload.DesiredSpeed, target.Payload.SpeedLimit);
end
target.Payload.LastDecision = "ChangeSpeed";
end

function target = reverseGroundBehaviorRoute(target)
target.Payload.Waypoints = flipud(target.Payload.Waypoints);
target.Payload.WaypointRoadIDs = flipud(target.Payload.WaypointRoadIDs);
target.Payload.WaypointSpeedLimits = flipud(target.Payload.WaypointSpeedLimits);
target.Payload.CurrentWaypointIndex = 1;
target.Payload.CurrentWaypoint = target.Payload.Waypoints(1, :).';
target.Payload.CurrentRoadID = target.Payload.WaypointRoadIDs(1);
target.Payload.SpeedLimit = target.Payload.WaypointSpeedLimits(1);
target.Payload.LastDecision = "TurnAround";
end

function targetTreeID = selectAlternateTreeForBehavior(bird, trees, config, oldTargetID, currentTreeID)
treeIDs = [trees.ID];
candidates = treeIDs(treeIDs ~= currentTreeID & treeIDs ~= oldTargetID);
if isempty(candidates)
    targetTreeID = [];
    return;
end

positions = reshape([trees.TopPosition], 3, []).';
candidateMask = ismember(treeIDs, candidates);
candidatePositions = positions(candidateMask, :);
distances = vecnorm(candidatePositions - bird.Position(:).', 2, 2);
[~, idx] = min(distances);
targetTreeID = candidates(idx);
end

function target = syncBehaviorGoalFromState(target)
if ~isfield(target, 'Behavior')
    return;
end
state = string(target.State);
if target.Class == "bird"
    switch state
        case "Perched", target.Behavior.CurrentGoal = "StayPerched";
        case "Takeoff", target.Behavior.CurrentGoal = "TakeoffToTree";
        case "Cruise", target.Behavior.CurrentGoal = "FlyToTree";
        case "Landing", target.Behavior.CurrentGoal = "LandOnTree";
        case "Hidden", target.Behavior.CurrentGoal = "HideInTree";
    end
elseif target.Class == "air"
    if target.Subtype == "fixedWingUAV"
        switch state
            case "Cruise", target.Behavior.CurrentGoal = "ReachWaypoint";
            case "Turn", target.Behavior.CurrentGoal = "AlignHeading";
            case "Climb", target.Behavior.CurrentGoal = "ClimbToAltitude";
            case "Descend", target.Behavior.CurrentGoal = "DescendToAltitude";
            case "Loiter", target.Behavior.CurrentGoal = "LoiterArea";
            case "Dive", target.Behavior.CurrentGoal = "Dive";
            case "Recover", target.Behavior.CurrentGoal = "RecoverAltitude";
            case "Return", target.Behavior.CurrentGoal = "ReturnHome";
            case "ExitArea", target.Behavior.CurrentGoal = "ExitArea";
        end
    else
        switch state
            case "Idle", target.Behavior.CurrentGoal = "WaitOnGround";
            case "Takeoff", target.Behavior.CurrentGoal = "TakeoffToAltitude";
            case "Transit", target.Behavior.CurrentGoal = "ReachWaypoint";
            case "Hover", target.Behavior.CurrentGoal = "ObserveArea";
            case "Scan", target.Behavior.CurrentGoal = "ScanArea";
            case "Return", target.Behavior.CurrentGoal = "ReturnHome";
            case "Landing", target.Behavior.CurrentGoal = "LandHome";
        end
    end
elseif target.Class == "ground"
    switch state
        case "Idle", target.Behavior.CurrentGoal = "WaitOnRoad";
        case "Drive", target.Behavior.CurrentGoal = "FollowRoad";
        case "Stop", target.Behavior.CurrentGoal = "HoldPosition";
        case "Turn", target.Behavior.CurrentGoal = "TurnAround";
        case "LeaveRoad", target.Behavior.CurrentGoal = "OffroadExcursion";
        case "ReturnRoad", target.Behavior.CurrentGoal = "ReturnToRoad";
    end
end
end
