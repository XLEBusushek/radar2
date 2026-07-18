function target = updateGroundBehavior(target, scenario, config, dt)
% updateGroundBehavior - Обновление поведения/FSM для наземных транспортных целей.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

target = updateGroundNavigation(target, scenario, config, dt);

if isfield(config, 'behavior') && isfield(config.behavior, 'enabled') && ...
        config.behavior.enabled
    target = updateBehaviorEngine(target, scenario, config, dt);
    target = applyMandatoryTargetTransitions(target, scenario, config);
    [target.Payload.DesiredVelocity, target.Payload.LookaheadPoint] = ...
        computeGroundDesiredVelocity(target, scenario, config);
    target.Payload.PurePursuitPoint = target.Payload.LookaheadPoint;
    return;
end

if ~config.groundVehicle.fsm.enabled
    [target.Payload.DesiredVelocity, target.Payload.LookaheadPoint] = ...
        computeGroundDesiredVelocity(target, scenario, config);
    target.Payload.PurePursuitPoint = target.Payload.LookaheadPoint;
    return;
end

if target.CurrentTime >= target.Payload.NextGroundDecisionTime
    action = groundDecisionEngine(target, config);
    target = applyGroundLegacyAction(target, action, scenario, config);
    periodRange = config.groundVehicle.decisionPeriodRange;
    target.Payload.NextGroundDecisionTime = target.CurrentTime + ...
        periodRange(1) + rand() * (periodRange(2) - periodRange(1));
end

target = updateGroundNavigation(target, scenario, config, dt);
[target.Payload.DesiredVelocity, target.Payload.LookaheadPoint] = ...
    computeGroundDesiredVelocity(target, scenario, config);
target.Payload.PurePursuitPoint = target.Payload.LookaheadPoint;
end

function target = applyGroundLegacyAction(target, action, scenario, config)
target.Payload.LastDecision = string(action);
switch string(action)
    case "ContinueDrive"
        if ismember(string(target.State), ["Idle", "Stop", "Turn"])
            target = transitionGroundState(target, "Drive", "legacy:continueDrive", config);
        end
    case "Stop"
        if ismember(string(target.State), ["Drive", "Turn"])
            target = transitionGroundState(target, "Stop", "legacy:stop", config);
        end
    case "ChangeSpeed"
        target = changeGroundDesiredSpeed(target, config);
    case "LeaveRoad"
        if string(target.State) == "Drive"
            target = leaveRoadTemporarily(target, scenario.RoadNetwork, config);
            target = transitionGroundState(target, "LeaveRoad", "legacy:leaveRoad", config);
        end
    case "ReturnRoad"
        if string(target.State) == "LeaveRoad"
            target = returnToRoad(target, scenario.RoadNetwork);
            target = transitionGroundState(target, "ReturnRoad", "legacy:returnRoad", config);
        end
    case "TurnAround"
        if string(target.State) == "Drive"
            target = reverseGroundRoute(target);
            target = transitionGroundState(target, "Turn", "legacy:turnAround", config);
        end
    otherwise
        % Wait/unknown не меняет текущее состояние.
end
end

function target = changeGroundDesiredSpeed(target, config)
factor = 0.8 + rand() * 0.5;
target.Payload.DesiredSpeed = min(max(target.Payload.DesiredSpeed * factor, ...
    config.groundVehicle.speedRange(1)), config.groundVehicle.speedRange(2));
target.Payload.LastDecision = "ChangeSpeed";
end

function target = reverseGroundRoute(target)
target.Payload.Waypoints = flipud(target.Payload.Waypoints);
target.Payload.WaypointRoadIDs = flipud(target.Payload.WaypointRoadIDs);
target.Payload.WaypointSpeedLimits = flipud(target.Payload.WaypointSpeedLimits);
target.Payload.CurrentWaypointIndex = 1;
target.Payload.CurrentWaypoint = target.Payload.Waypoints(1, :).';
target.Payload.CurrentRoadID = target.Payload.WaypointRoadIDs(1);
target.Payload.SpeedLimit = target.Payload.WaypointSpeedLimits(1);
target.Payload.LastDecision = "TurnAround";
end
