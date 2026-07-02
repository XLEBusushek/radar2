function nextState = fixedWingDecisionEngine(target, config)
% fixedWingDecisionEngine - Local stochastic FSM for fixed-wing UAVs.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

state = string(target.State);
fw = config.fixedWing;
nextState = state;
allowExitArea = isfield(fw, 'allowExitArea') && fw.allowExitArea;
nearBoundary = isfield(target.Payload, 'NearBoundary') && target.Payload.NearBoundary;
nearWaypointZone = isFixedWingNearWaypointManeuverZone(target, config);

if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    return;
end

switch state
    case "Cruise"
        if nearWaypointZone
            if abs(wrapToPiLocal(target.Payload.TargetHeading - target.Payload.CurrentHeading)) > deg2rad(15)
                nextState = "Turn";
            end
        elseif rand() < fw.returnProbability
            nextState = "Return";
        elseif ~nearBoundary && rand() < fw.diveProbability && ...
                target.Position(3) > fw.operatingAltitudeRange(1) + 40
            nextState = "Dive";
        elseif ~nearBoundary && rand() < 0.05 && isNearFixedWingWaypoint(target, fw)
            nextState = "Loiter";
        elseif rand() < 0.08
            if target.Position(3) < mean(fw.operatingAltitudeRange)
                nextState = "Climb";
            else
                nextState = "Descend";
            end
        elseif abs(wrapToPiLocal(target.Payload.TargetHeading - target.Payload.CurrentHeading)) > deg2rad(15)
            nextState = "Turn";
        end
    case "Turn"
        if target.TimeInState >= fw.turn.minTurnDuration && ...
                abs(wrapToPiLocal(target.Payload.TargetHeading - target.Payload.CurrentHeading)) < deg2rad(5)
            nextState = "Cruise";
        end
    case {"Climb", "Descend"}
        if abs(target.Payload.DesiredAltitude - target.Position(3)) < 8
            nextState = "Cruise";
        end
    case "Loiter"
        if ~isempty(target.Payload.LoiterStartTime) && ...
                target.CurrentTime >= target.Payload.LoiterStartTime + target.Payload.LoiterDuration
            nextState = "Cruise";
        end
    case "Dive"
        if ~isempty(target.Payload.DiveStartTime) && ...
                target.CurrentTime >= target.Payload.DiveStartTime + target.Payload.DiveDuration
            nextState = "Recover";
        end
    case "Recover"
        if target.Position(3) >= target.Payload.DesiredAltitude - 8
            nextState = "Cruise";
        end
    case "Return"
        if norm(target.Payload.HomePosition(1:2) - target.Position(1:2)) <= target.Payload.WaypointArrivalRadius
            if allowExitArea
                nextState = "ExitArea";
            else
                nextState = "Cruise";
            end
        end
end
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end

function near = isNearFixedWingWaypoint(target, fw)
arrivalRadius = target.Payload.WaypointArrivalRadius;
if isfield(fw, 'navigation') && isfield(fw.navigation, 'arrivalRadius')
    arrivalRadius = fw.navigation.arrivalRadius;
end
near = isFixedWingWaypointReached(target, fw, arrivalRadius);
end

function reached = isFixedWingWaypointReached(target, fw, arrivalRadius)
reached = target.Payload.DistanceToWaypoint <= arrivalRadius;
if reached
    return;
end
if isfield(fw, 'navigation') && isfield(fw.navigation, 'cornerCuttingEnabled') && ...
        fw.navigation.cornerCuttingEnabled && ...
        isfield(target.Payload, 'CornerCuttingActive') && target.Payload.CornerCuttingActive && ...
        isfield(fw.navigation, 'cornerCuttingRadius')
    effectiveRadius = fw.navigation.cornerCuttingRadius;
    if isfield(fw.navigation, 'arcTurnEnabled') && fw.navigation.arcTurnEnabled
        arcRadius = 300;
        if isfield(fw, 'turn') && isfield(fw.turn, 'minTurnRadius')
            arcRadius = fw.turn.minTurnRadius;
        elseif isfield(fw.navigation, 'desiredTurnRadius')
            arcRadius = fw.navigation.desiredTurnRadius;
        end
        effectiveRadius = max(effectiveRadius, arcRadius * 1.4);
    end
    reached = target.Payload.DistanceToWaypoint <= effectiveRadius;
end
end
