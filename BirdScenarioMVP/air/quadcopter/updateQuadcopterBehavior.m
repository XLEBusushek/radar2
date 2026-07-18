function target = updateQuadcopterBehavior(target, scenario, config, dt)
% updateQuadcopterBehavior - Обновление FSM для целей-квадрокоптеров.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

wp = target.Payload.CurrentWaypoint(:);
target.Payload.DistanceToWaypoint = norm(wp - target.Position);
if isfield(config.quadcopter, 'navigation') && config.quadcopter.navigation.enabled
    target = updateQuadcopterNavigationProgress(target, config, dt);
end

if isfield(config, 'behavior') && isfield(config.behavior, 'enabled') && ...
        config.behavior.enabled
    target = updateBehaviorEngine(target, scenario, config, dt);
    target = applyMandatoryTargetTransitions(target, scenario, config);
    target = updateQuadcopterMotionCommand(target, config);
    return;
end

if ~config.quadcopter.fsm.enabled
    target = updateQuadcopterMotionCommand(target, config);
    return;
end

nextState = quadcopterDecisionEngine(target, config);
currentState = string(target.State);
atWaypoint = target.Payload.DistanceToWaypoint <= target.Payload.WaypointArrivalRadius;

if nextState ~= currentState
    reason = sprintf('%s_to_%s', currentState, nextState);
    target = transitionQuadcopterState(target, nextState, reason, config);
elseif currentState == "Transit" && atWaypoint && ...
        target.Payload.CurrentWaypointIndex < size(target.Payload.Waypoints, 1)
    target = advanceQuadcopterWaypoint(target, config);
    target.Payload.LastTransitionReason = 'waypoint_advanced';
end

target = updateQuadcopterMotionCommand(target, config);
end
