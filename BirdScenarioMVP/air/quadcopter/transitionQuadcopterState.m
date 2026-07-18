function target = transitionQuadcopterState(target, nextState, reason, config)
% transitionQuadcopterState - Применить переход FSM с действиями при входе в состояние.
arguments
    target (1, 1) struct
    nextState (1, 1) string
    reason (1, 1) string
    config (1, 1) struct
end

currentState = string(target.State);
nextState = string(nextState);

if currentState == nextState
    return;
end

if ~isQuadcopterTransitionAllowed(currentState, nextState)
    error('transitionQuadcopterState:InvalidTransition', ...
        'Transition %s -> %s is not allowed.', currentState, nextState);
end

target.Payload.LastState = currentState;
target.Payload.NextState = nextState;
target.Payload.LastTransitionReason = reason;
target.Payload.TransitionCount = target.Payload.TransitionCount + 1;
target.Payload.StateEntryTime = target.CurrentTime;

target.State = nextState;
target.TimeInState = 0;

switch nextState
    case "Takeoff"
        target = initializeQuadcopterTakeoff(target, config);
    case "Transit"
        target.Payload.ConsecutiveHoverCount = 0;
        target.Payload.ConsecutiveScanCount = 0;
        speedRange = config.quadcopter.transitSpeedRange;
        target.Payload.DesiredSpeed = speedRange(1) + rand() * (speedRange(2) - speedRange(1));
        if isfield(target.Payload, 'CurrentWaypoint') && ~isempty(target.Payload.CurrentWaypoint)
            target.Payload.DesiredAltitude = target.Payload.CurrentWaypoint(3);
        end
        if ~target.Payload.ForceDirectToWaypoint
            target.Payload.LastNavigationEvent = "transit";
        end
    case "Hover"
        target.Payload.ConsecutiveHoverCount = target.Payload.ConsecutiveHoverCount + 1;
        target.Payload.ConsecutiveScanCount = 0;
        target.Payload.LastNavigationEvent = "hover";
        target = initializeQuadcopterHover(target, config);
    case "Scan"
        target.Payload.ConsecutiveScanCount = target.Payload.ConsecutiveScanCount + 1;
        target.Payload.ConsecutiveHoverCount = 0;
        target.Payload.LastNavigationEvent = "scan";
        target = initializeQuadcopterScan(target, config);
    case "Return"
        target.Payload.ForceDirectToWaypoint = true;
        target.Payload.LastNavigationEvent = "returnHome";
        target = initializeQuadcopterReturn(target, config);
    case "Landing"
        target = initializeQuadcopterLanding(target, config);
end
end
