function nextState = quadcopterDecisionEngine(target, config)
% quadcopterDecisionEngine - Определить следующее состояние FSM для квадрокоптера.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

currentState = string(target.State);
nextState = currentState;
qc = config.quadcopter;

switch currentState
    case "Idle"
        nextState = decideIdleTransition(target, qc);
    case "Takeoff"
        if target.Position(3) >= target.Payload.TakeoffTargetAltitude - 2
            nextState = "Transit";
        end
    case "Transit"
        nextState = decideTransitTransition(target, qc);
    case "Hover"
        nextState = decideHoverTransition(target, qc);
    case "Scan"
        if target.CurrentTime >= target.Payload.ScanStartTime + target.Payload.ScanDuration
            nextState = "Transit";
        end
    case "Return"
        nextState = decideReturnTransition(target, qc);
    case "Landing"
        if target.Position(3) <= qc.landingAltitudeThreshold
            nextState = "Idle";
        end
end
end

function nextState = decideIdleTransition(target, qc)
nextState = "Idle";
if target.TimeInState < qc.fsm.idle.minTime
    return;
end
if target.TimeInState >= qc.fsm.idle.maxTime
    nextState = "Takeoff";
    return;
end
if rand() < qc.fsm.idle.takeoffProbability
    nextState = "Takeoff";
end
end

function nextState = decideTransitTransition(target, qc)
nextState = "Transit";

if isfield(target.Payload, 'ForceDirectToWaypoint') && target.Payload.ForceDirectToWaypoint
    if target.Payload.DistanceToWaypoint <= target.Payload.WaypointArrivalRadius && ...
            target.Payload.CurrentWaypointIndex >= size(target.Payload.Waypoints, 1)
        nextState = "Return";
    end
    return;
end

if qc.fsm.return.enabled && rand() < qc.fsm.returnProbability
    nextState = "Return";
    return;
end

if target.Payload.DistanceToWaypoint > target.Payload.WaypointArrivalRadius
    return;
end

numWaypoints = size(target.Payload.Waypoints, 1);
idx = target.Payload.CurrentWaypointIndex;

if idx >= numWaypoints
    nextState = "Return";
    return;
end

r = rand();
hoverProb = qc.fsm.transit.hoverProbability;
scanProb = qc.fsm.transit.scanProbability;
nextWaypointProb = qc.fsm.transit.nextWaypointProbability;

if target.Payload.ConsecutiveHoverCount >= qc.navigation.maxConsecutiveHover
    hoverProb = 0;
end
if target.Payload.ConsecutiveScanCount >= qc.navigation.maxConsecutiveScan
    scanProb = 0;
end

if r < hoverProb
    nextState = "Hover";
elseif r < hoverProb + scanProb
    nextState = "Scan";
elseif r < hoverProb + scanProb + nextWaypointProb
    nextState = "Transit";
else
    nextState = "Transit";
end
end

function nextState = decideHoverTransition(target, qc)
nextState = "Hover";
if shouldForceQuadcopterTransit(target, struct('quadcopter', qc))
    nextState = "Transit";
    return;
end
if target.TimeInState < target.Payload.HoverDuration
    return;
end
nextState = "Transit";
end

function nextState = decideReturnTransition(target, qc)
nextState = "Return";
home = target.Payload.HomePosition(:);
delta = home - target.Position;
distXY = norm(delta(1:2));
altDiff = abs(delta(3));

if distXY <= target.Payload.WaypointArrivalRadius && altDiff <= 5
    nextState = "Landing";
end
end
