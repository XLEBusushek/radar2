function target = enterFinalPhase(target, config)
% enterFinalPhase - Заблокировать fixed-wing UAV в неизменяемой фазе завершения миссии.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

if isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    return;
end

fw = config.fixedWing;
allowExitArea = isfield(fw, 'allowExitArea') && fw.allowExitArea;

if isempty(target.Payload.FinalCruiseSpeed) || isnan(target.Payload.FinalCruiseSpeed)
    target.Payload.FinalCruiseSpeed = target.Payload.SmoothedDesiredSpeed;
end
if isempty(target.Payload.FinalCruiseSpeed) || isnan(target.Payload.FinalCruiseSpeed)
    target.Payload.FinalCruiseSpeed = mean(fw.cruiseSpeedRange);
end

strategy = string(target.Payload.FinalStrategy);
if strategy == "" || strlength(strategy) == 0
    target.Payload.FinalStrategy = selectFinalStrategyLocal(fw);
    strategy = string(target.Payload.FinalStrategy);
end

if ~allowExitArea && strategy == "Exit"
    strategy = "NewRoute";
    target.Payload.FinalStrategy = strategy;
end

if strategy == "NewRoute"
    target.Payload.FinalPhaseStarted = true;
    target.Payload.FinalPhase = true;
    target.Payload.FinalMissionCompleted = true;
    target.Payload.MissionComplete = false;
    target = regenerateFixedWingMission(target, config);
    target.Payload.FinalPhaseStarted = false;
    target.Payload.FinalPhase = false;
    target.Payload.FinalMissionCompleted = false;
    target.Payload.LastNavigationEvent = "finalPhase:newRoute";
    return;
end

target.Payload.FinalPhaseStarted = true;
target.Payload.FinalPhase = true;
target.Payload.TimeInFinalPhase = 0;
target.Payload.FinalMissionCompleted = false;
target.Payload.MissionComplete = true;
target.Payload.ForceDirectToWaypoint = false;
target.Payload.CornerCuttingActive = false;
target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
target.Payload.DesiredSpeed = target.Payload.FinalCruiseSpeed;
target.Payload.SmoothedDesiredSpeed = target.Payload.FinalCruiseSpeed;
target.Payload.NavigationLookaheadPoint = target.Payload.ExitPoint(:);

switch strategy
    case "Exit"
        target = transitionFixedWingState(target, "ApproachExit", "finalPhase:exit", config);
    case "ReturnHome"
        target = transitionFixedWingState(target, "ReturnHome", "finalPhase:returnHome", config);
    case "LoiterEnd"
        target = initializeLoiterEnd(target, config);
        target = transitionFixedWingState(target, "LoiterEnd", "finalPhase:loiterEnd", config);
    otherwise
        target.Payload.FinalStrategy = "ReturnHome";
        target = transitionFixedWingState(target, "ReturnHome", "finalPhase:fallback", config);
end
end

function strategy = selectFinalStrategyLocal(fw)
allowExitArea = isfield(fw, 'allowExitArea') && fw.allowExitArea;
if allowExitArea
    weights = [0.6, 0.2, 0.2];
    labels = ["Exit", "ReturnHome", "LoiterEnd"];
else
    weights = [0.6, 0.2, 0.2];
    labels = ["NewRoute", "ReturnHome", "LoiterEnd"];
end
if isfield(fw, 'finalPhase') && isfield(fw.finalPhase, 'strategyWeights')
    if allowExitArea
        weights = [fw.finalPhase.strategyWeights.Exit, ...
            fw.finalPhase.strategyWeights.ReturnHome, ...
            fw.finalPhase.strategyWeights.LoiterEnd];
    elseif isfield(fw.finalPhase.strategyWeights, 'NewRoute')
        weights = [fw.finalPhase.strategyWeights.NewRoute, ...
            fw.finalPhase.strategyWeights.ReturnHome, ...
            fw.finalPhase.strategyWeights.LoiterEnd];
    else
        weights = [fw.finalPhase.strategyWeights.Exit, ...
            fw.finalPhase.strategyWeights.ReturnHome, ...
            fw.finalPhase.strategyWeights.LoiterEnd];
    end
end
weights = max(weights, 0);
weights = weights / sum(weights);
r = rand();
if r < weights(1)
    strategy = labels(1);
elseif r < weights(1) + weights(2)
    strategy = labels(2);
else
    strategy = labels(3);
end
end

function target = initializeLoiterEnd(target, config)
fp = config.fixedWing.finalPhase;
radius = sampleRange(fp.loiterEndRadiusRange);
heading = target.Payload.CurrentHeading;
radial = [cos(heading + pi / 2); sin(heading + pi / 2)];
target.Payload.LoiterEndRadius = radius;
target.Payload.LoiterEndCenter = target.Position(:) - radius * [radial; 0];
target.Payload.LoiterEndAngle = atan2(target.Position(2) - target.Payload.LoiterEndCenter(2), ...
    target.Position(1) - target.Payload.LoiterEndCenter(1));
target.Payload.LoiterEndDirection = 1;
target.Payload.LoiterEndLoopProgress = 0;
target.Payload.LoiterEndCompleted = false;
end

function value = sampleRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
