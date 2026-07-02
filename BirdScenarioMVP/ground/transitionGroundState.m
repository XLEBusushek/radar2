function target = transitionGroundState(target, nextState, reason, config)
% transitionGroundState - Apply ground vehicle FSM transition.
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

if ~isTransitionAllowed(currentState, nextState)
    error('transitionGroundState:InvalidTransition', ...
        'Transition %s -> %s is not allowed.', currentState, nextState);
end

target.Payload.LastState = currentState;
target.Payload.NextState = nextState;
target.Payload.LastTransitionReason = reason;
target.Payload.TransitionCount = target.Payload.TransitionCount + 1;
target.Payload.StateEntryTime = target.CurrentTime;
target.Payload.LastDecision = erase("behavior:" + reason, "behavior:behavior:");

target.State = nextState;
target.TimeInState = 0;

switch nextState
    case "Idle"
        target.Payload.DesiredSpeed = 0;
        target.Payload.DesiredVelocity = zeros(3, 1);
    case "Drive"
        target.Payload.DesiredSpeed = selectDriveSpeed(target, config);
        target.Payload.OffroadTarget = [];
        target.Payload.ReturnRoadPoint = [];
    case "Stop"
        stopRange = config.groundVehicle.stopDurationRange;
        target.Payload.StopUntilTime = target.CurrentTime + ...
            stopRange(1) + rand() * (stopRange(2) - stopRange(1));
        target.Payload.DesiredSpeed = 0;
    case "Turn"
        target.Payload.DesiredSpeed = max(config.groundVehicle.speedRange(1), ...
            0.5 * target.Payload.DesiredSpeed);
    case "LeaveRoad"
        target.Payload.DesiredSpeed = max(config.groundVehicle.speedRange(1), ...
            target.Payload.DesiredSpeed * config.groundVehicle.offroadSpeedFactor);
    case "ReturnRoad"
        target.Payload.DesiredSpeed = max(config.groundVehicle.speedRange(1), ...
            target.Payload.DesiredSpeed * config.groundVehicle.offroadSpeedFactor);
end
end

function allowed = isTransitionAllowed(currentState, nextState)
switch currentState
    case "Idle"
        allowed = ismember(nextState, ["Drive", "Stop"]);
    case "Drive"
        allowed = ismember(nextState, ["Stop", "Turn", "LeaveRoad", "Idle"]);
    case "Stop"
        allowed = ismember(nextState, ["Drive", "Idle"]);
    case "Turn"
        allowed = ismember(nextState, ["Drive", "Stop"]);
    case "LeaveRoad"
        allowed = ismember(nextState, ["ReturnRoad", "Stop"]);
    case "ReturnRoad"
        allowed = ismember(nextState, ["Drive", "Stop"]);
    otherwise
        allowed = false;
end
end

function speed = selectDriveSpeed(target, config)
gv = config.groundVehicle;
speedLimit = target.Payload.SpeedLimit;
if isnan(speedLimit) || speedLimit <= 0
    speedLimit = gv.speedRange(2);
end
bias = mean([target.Payload.DriverAggression, target.Payload.SpeedBias]);
base = gv.speedRange(1) + (gv.speedRange(2) - gv.speedRange(1)) * min(max((bias - 0.5), 0), 1);
speed = min([base, speedLimit, gv.speedRange(2)]);
speed = max(speed, gv.speedRange(1));
end
