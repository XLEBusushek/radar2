function target = applyMandatoryTargetTransitions(target, scenario, config)
% applyMandatoryTargetTransitions - Deterministic FSM transitions (no randomness).
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
end

if target.Class == "bird"
    target = applyMandatoryBirdTransitions(target, scenario, config);
elseif target.Class == "air" && target.Subtype == "quadcopter"
    target = applyMandatoryQuadcopterTransitions(target, config);
elseif target.Class == "air" && target.Subtype == "fixedWingUAV"
    target = applyMandatoryFixedWingTransitions(target, config);
elseif target.Class == "ground" && target.Subtype == "vehicle"
    target = applyMandatoryGroundTransitions(target, scenario, config);
end
end

function bird = applyMandatoryBirdTransitions(bird, scenario, config)
state = string(bird.State);

switch state
    case "Takeoff"
        if ~isempty(bird.Payload.TakeoffTargetAltitude) && ...
                bird.Position(3) >= bird.Payload.TakeoffTargetAltitude - 1
            bird = transitionBirdState(bird, "Cruise", scenario, config, "takeoffComplete");
        elseif bird.TimeInState >= getBirdFSMConfig("Takeoff", config).maxTime
            bird = transitionBirdState(bird, "Cruise", scenario, config, "maxTime");
        end
    case "Cruise"
        blockLanding = isfield(bird.Payload, 'BlockLandingThisStep') && bird.Payload.BlockLandingThisStep;
        if ~blockLanding && isCloseToTargetTreeForLanding(bird, config)
            bird = transitionBirdState(bird, "Landing", scenario, config, "arrivalRadius");
        end
        bird.Payload.BlockLandingThisStep = false;
    case "Landing"
        if isfield(bird.Payload, 'LandingComplete') && bird.Payload.LandingComplete
            bird = transitionBirdState(bird, "Hidden", scenario, config, "landingComplete");
        elseif isBirdLandingComplete(bird, config)
            bird = transitionBirdState(bird, "Hidden", scenario, config, "landingComplete");
        end
    case "Hidden"
        if isfield(config.birds, 'realism') && config.birds.realism.enabled && ...
                isfield(bird.Payload, 'HiddenExtended') && bird.Payload.HiddenExtended && ...
                isfield(bird.Payload, 'HiddenDuration') && ...
                bird.TimeInState < bird.Payload.HiddenDuration
            return;
        end
        if bird.TimeInState >= getBirdFSMConfig("Hidden", config).maxTime
            bird = transitionBirdState(bird, "Perched", scenario, config, "maxTime");
        end
end
end

function target = applyMandatoryGroundTransitions(target, scenario, config)
state = string(target.State);
switch state
    case "Idle"
        if target.TimeInState >= target.Behavior.DecisionPeriod
            target = transitionGroundState(target, "Drive", "idleComplete", config);
        end
    case "Drive"
        if target.Payload.DistanceToWaypoint <= target.Payload.WaypointArrivalRadius
            target = advanceGroundWaypoint(target, config);
        end
    case "Stop"
        if target.CurrentTime >= target.Payload.StopUntilTime
            target = transitionGroundState(target, "Drive", "stopComplete", config);
        end
    case "Turn"
        if target.TimeInState >= 2
            target = transitionGroundState(target, "Drive", "turnComplete", config);
        end
    case "LeaveRoad"
        if ~isempty(target.Payload.OffroadTarget) && ...
                norm(target.Payload.OffroadTarget(:) - target.Position(:)) <= target.Payload.WaypointArrivalRadius
            target = returnToRoad(target, scenario.RoadNetwork);
            target = transitionGroundState(target, "ReturnRoad", "offroadComplete", config);
        end
    case "ReturnRoad"
        if isempty(target.Payload.ReturnRoadPoint) && isfield(scenario, 'RoadNetwork')
            target = returnToRoad(target, scenario.RoadNetwork);
        end
        if target.Payload.RoadDeviation <= config.groundVehicle.roadDeviationTolerance
            target = transitionGroundState(target, "Drive", "roadReached", config);
        end
end
end

function target = applyMandatoryQuadcopterTransitions(target, config)
state = string(target.State);
qc = config.quadcopter;

switch state
    case "Takeoff"
        if ~isempty(target.Payload.TakeoffTargetAltitude) && ...
                target.Position(3) >= target.Payload.TakeoffTargetAltitude - 2
            target = transitionQuadcopterState(target, "Transit", "takeoffComplete", config);
        end
    case "Transit"
        atWaypoint = target.Payload.DistanceToWaypoint <= target.Payload.WaypointArrivalRadius;
        if atWaypoint && target.Payload.CurrentWaypointIndex >= size(target.Payload.Waypoints, 1)
            target = transitionQuadcopterState(target, "Return", "missionComplete", config);
        elseif atWaypoint && target.Payload.CurrentWaypointIndex < size(target.Payload.Waypoints, 1)
            target = advanceQuadcopterWaypoint(target, config);
            target.Payload.LastTransitionReason = 'waypoint_reached';
        end
    case "Hover"
        if shouldForceQuadcopterTransit(target, config) || ...
                (~isempty(target.Payload.HoverDuration) && ...
                target.TimeInState >= target.Payload.HoverDuration)
            target = transitionQuadcopterState(target, "Transit", "hoverComplete", config);
        end
    case "Scan"
        if shouldForceQuadcopterTransit(target, config) || ...
                (~isempty(target.Payload.ScanStartTime) && ~isempty(target.Payload.ScanDuration) && ...
                target.CurrentTime >= target.Payload.ScanStartTime + target.Payload.ScanDuration)
            target = transitionQuadcopterState(target, "Transit", "scanComplete", config);
        end
    case "Return"
        home = target.Payload.HomePosition(:);
        delta = home - target.Position;
        if norm(delta(1:2)) <= target.Payload.WaypointArrivalRadius && abs(delta(3)) <= 5
            target = transitionQuadcopterState(target, "Landing", "atHome", config);
        end
    case "Landing"
        if target.Position(3) <= qc.landingAltitudeThreshold
            target.Position(3) = 0;
            target.Velocity = zeros(3, 1);
            target.Acceleration = zeros(3, 1);
            target.Payload.MissionComplete = true;
            target = transitionQuadcopterState(target, "Idle", "landed", config);
        end
end
end

function target = applyMandatoryFixedWingTransitions(target, config)
state = string(target.State);
fw = config.fixedWing;

if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    return;
end

if isfield(fw, 'finalPhase') && fw.finalPhase.enabled
    finalPhasePending = shouldEnterFixedWingFinalPhase(target, config);
else
    finalPhasePending = false;
end

target.Payload.DistanceToWaypoint = computeFixedWingWaypointDistance(target);
arrivalRadius = target.Payload.WaypointArrivalRadius;
if isfield(fw, 'navigation') && isfield(fw.navigation, 'arrivalRadius')
    arrivalRadius = fw.navigation.arrivalRadius;
end

switch state
    case "Cruise"
        if isFixedWingWaypointReached(target, fw, arrivalRadius)
            target = advanceFixedWingWaypoint(target, config);
            if target.Payload.MissionComplete && ~finalPhasePending && ...
                    (~isfield(fw, 'finalPhase') || ~fw.finalPhase.enabled)
                target = transitionFixedWingState(target, "Return", "missionComplete", config);
            end
        end
    case "Turn"
        minTurnDuration = fw.turn.minTurnDuration;
        if isFixedWingWaypointReached(target, fw, arrivalRadius)
            target = advanceFixedWingWaypoint(target, config);
        elseif target.TimeInState >= minTurnDuration && ...
                abs(wrapToPiLocal(target.Payload.TargetHeading - target.Payload.CurrentHeading)) < deg2rad(5)
            target = transitionFixedWingState(target, "Cruise", "turnComplete", config);
        end
    case {"Climb", "Descend"}
        if target.Position(3) >= target.Payload.AltitudeBand(1) && ...
                target.Position(3) <= target.Payload.AltitudeBand(2)
            target = transitionFixedWingState(target, "Cruise", "altitudeReached", config);
        end
    case "Loiter"
        if ~isempty(target.Payload.LoiterStartTime) && ~isempty(target.Payload.LoiterDuration) && ...
                target.CurrentTime >= target.Payload.LoiterStartTime + target.Payload.LoiterDuration
            target = transitionFixedWingState(target, "Cruise", "loiterComplete", config);
        end
    case "Dive"
        if ~isempty(target.Payload.DiveStartTime) && ~isempty(target.Payload.DiveDuration) && ...
                (target.CurrentTime >= target.Payload.DiveStartTime + target.Payload.DiveDuration || ...
                target.Position(3) <= target.Payload.DiveTargetAltitude + 5)
            target = transitionFixedWingState(target, "Recover", "diveComplete", config);
        end
    case "Recover"
        if target.TimeInState > 0 && ...
                target.Position(3) >= target.Payload.AltitudeBand(1) && ...
                target.Position(3) <= target.Payload.AltitudeBand(2)
            target = transitionFixedWingState(target, "Cruise", "recoverComplete", config);
        end
    case "Return"
        if norm(target.Payload.HomePosition(1:2) - target.Position(1:2)) <= ...
                max(target.Payload.WaypointArrivalRadius, fw.minTurnRadius / 2)
            if isfield(fw, 'allowExitArea') && fw.allowExitArea
                target = transitionFixedWingState(target, "ExitArea", "homeReached", config);
            else
                target = regenerateFixedWingMission(target, config);
            end
        end
end
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
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
        elseif isfield(fw, 'navigation') && isfield(fw.navigation, 'desiredTurnRadius')
            arcRadius = fw.navigation.desiredTurnRadius;
        end
        effectiveRadius = max(effectiveRadius, arcRadius * 1.4);
    end
    reached = target.Payload.DistanceToWaypoint <= effectiveRadius;
end
end
