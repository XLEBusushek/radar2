function target = updateFixedWingBehavior(target, scenario, config, dt)
% updateFixedWingBehavior - FSM and behavior update for fixed-wing UAV targets.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

target.Payload.DistanceToWaypoint = computeFixedWingWaypointDistance(target);
target.Payload.MaxAltitudeReached = max(target.Payload.MaxAltitudeReached, target.Position(3));
target.Payload.MinAltitudeReached = min(target.Payload.MinAltitudeReached, target.Position(3));
target.Payload.TotalXYExcursion = target.Payload.TotalXYExcursion + ...
    norm(target.Position(1:2) - target.Payload.LastPositionForExcursion(1:2));
target.Payload.LastPositionForExcursion = target.Position;

if isfield(target.Payload, 'TimeOnCurrentLeg')
    target.Payload.TimeOnCurrentLeg = target.Payload.TimeOnCurrentLeg + dt;
end

target = updateFixedWingActiveLeg(target, config, dt);
target = updateFixedWingBoundaryState(target, config, dt);
target = detectBorderFollowing(target, config, dt);

inReturnHomeFinal = isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted && ...
    isfield(target.Payload, 'FinalStrategy') && string(target.Payload.FinalStrategy) == "ReturnHome";
skipBorderHandling = string(target.State) == "ReturnHome" || inReturnHomeFinal;

if ~skipBorderHandling && target.Payload.BorderFollowing && string(target.State) ~= "BorderAvoidance"
    target = transitionFixedWingState(target, "BorderAvoidance", "borderFollowing", config);
end

if ~skipBorderHandling && (string(target.State) == "BorderAvoidance" || target.Payload.BorderFollowing)
    target = updateBorderAvoidance(target, config, dt);
    target = updateFixedWingMotionCommand(target, config, dt);
    target = applyMandatoryTargetTransitions(target, scenario, config);
    return;
end

if ~skipBorderHandling && isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive
    target = applyFixedWingBoundaryRecovery(target, config, dt);
    target = updateFixedWingMotionCommand(target, config, dt);
    target = applyMandatoryTargetTransitions(target, scenario, config);
    return;
end

if isempty(target.Payload.NavigationMode) || target.Payload.NavigationMode == ""
    target.Payload.NavigationMode = "Mission";
end

if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    target = updateFixedWingFinalPhaseMotion(target, scenario, config, dt);
    return;
end

if isfield(config, 'behavior') && isfield(config.behavior, 'enabled') && config.behavior.enabled
    target = updateBehaviorEngine(target, scenario, config, dt);
elseif isfield(config.fixedWing, 'fsm') && isfield(config.fixedWing.fsm, 'enabled') && ...
        config.fixedWing.fsm.enabled
    nextState = fixedWingDecisionEngine(target, config);
    if nextState ~= string(target.State)
        target = transitionFixedWingState(target, nextState, "fsm:" + nextState, config);
    end
end

target = applyMandatoryTargetTransitions(target, scenario, config);

if shouldEnterFixedWingFinalPhase(target, config)
    target = enterFinalPhase(target, config);
    if isfield(target.Payload, 'LastNavigationEvent') && ...
            target.Payload.LastNavigationEvent == "finalPhase:newRoute"
        target = updateFixedWingMotionCommand(target, config, dt);
        return;
    end
end

if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    target = updateFixedWingFinalPhaseMotion(target, scenario, config, dt);
    return;
end

target.Payload.NavigationMode = "Mission";
target = updateFixedWingMotionCommand(target, config, dt);
end

function target = updateFixedWingFinalPhaseMotion(target, scenario, config, dt)
if isfield(target.Payload, 'FinalMissionCompleted') && target.Payload.FinalMissionCompleted
    target = maintainCompletedFinalPhaseMotion(target, config);
else
    target = updateFinalNavigation(target, scenario, config, dt);
end
end

function target = maintainCompletedFinalPhaseMotion(target, config)
heading = target.Payload.CurrentHeading;
speed = max(config.fixedWing.minSpeed, target.Payload.FinalCruiseSpeed * 0.85);
target.Payload.SmoothedDesiredSpeed = speed;
target.Payload.DesiredVelocity = [cos(heading) * speed; sin(heading) * speed; 0];
target.Payload.DesiredSpeed = speed;
end
