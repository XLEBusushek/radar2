function target = updateFinalNavigation(target, scenario, config, dt)
% updateFinalNavigation - Dedicated mission completion navigation for fixed-wing UAVs.
arguments
    target (1, 1) struct
    scenario (1, 1) struct %#ok<INUSD>
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

fp = config.fixedWing.finalPhase;
allowExitArea = isfield(config.fixedWing, 'allowExitArea') && config.fixedWing.allowExitArea;
target.Payload.TimeInFinalPhase = target.Payload.TimeInFinalPhase + dt;
strategy = string(target.Payload.FinalStrategy);
state = string(target.State);

target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
target = applyFixedWingAltitudeSmoothing(target, config);
target = computeFixedWingAltitudeCommand(target, config);

targetHeading = target.Payload.TargetHeading;
switch strategy
    case "Exit"
        if allowExitArea
            [target, targetHeading] = updateExitStrategy(target, config, dt);
        else
            [target, targetHeading] = updateReturnHomeStrategy(target, config, dt);
        end
    case "ReturnHome"
        [target, targetHeading] = updateReturnHomeStrategy(target, config, dt);
    case "LoiterEnd"
        [target, targetHeading] = updateLoiterEndStrategy(target, config, dt);
end

target.Payload.TargetHeading = targetHeading;
target = applyFinalPhaseHeadingSmoothing(target, targetHeading, config, dt);
target = applyFinalPhaseSpeedLock(target, config);

heading = target.Payload.CurrentHeading;
speed = target.Payload.SmoothedDesiredSpeed;
vz = target.Payload.DesiredClimbRate;
target.Payload.DesiredVelocity = [cos(heading) * speed; sin(heading) * speed; vz];
target.Payload.DesiredSpeed = speed;
navEvent = "finalPhase:" + lower(strategy) + ":" + lower(state);
if string(target.Payload.LastNavigationEvent) ~= "finalPhase:loiterEndNewRoute"
    target.Payload.LastNavigationEvent = navEvent;
end
end

function [target, targetHeading] = updateExitStrategy(target, config, dt)
fp = config.fixedWing.finalPhase;
state = string(target.State);
exitPoint = target.Payload.ExitPoint(:);
distance = norm(exitPoint(1:2) - target.Position(1:2));

switch state
    case "ApproachExit"
        targetHeading = computeExitHeading(target.Position, exitPoint);
        target.Payload.NavigationLookaheadPoint = exitPoint;
        if distance <= fp.approachExitArrivalRadius
            target = transitionFixedWingState(target, "AlignExit", "finalPhase:approachComplete", config);
            targetHeading = target.Payload.FinalExitHeading;
        end
    case "AlignExit"
        targetHeading = target.Payload.FinalExitHeading;
        headingError = abs(wrapToPiLocal(targetHeading - target.Payload.CurrentHeading));
        if headingError <= deg2rad(fp.exitAlignThresholdDeg) || distance <= fp.approachExitArrivalRadius * 0.75
            target = transitionFixedWingState(target, "Exit", "finalPhase:aligned", config);
            targetHeading = target.Payload.FinalExitHeading;
        end
    case "Exit"
        targetHeading = target.Payload.FinalExitHeading;
        target.Payload.NavigationLookaheadPoint = target.Position(:) + ...
            [cos(targetHeading); sin(targetHeading); 0] * fp.approachExitArrivalRadius;
        if hasExitedWorld(target.Position, config)
            target.Payload.FinalMissionCompleted = true;
            target.Payload.MissionComplete = true;
        end
end

if target.Payload.TimeInFinalPhase >= 45 && ismember(state, ["ApproachExit", "AlignExit"])
    if isnan(target.Payload.FinalExitHeading)
        target.Payload.FinalExitHeading = computeExitHeading(target.Position, exitPoint);
    end
    target = transitionFixedWingState(target, "Exit", "finalPhase:timeoutExit", config);
    targetHeading = target.Payload.FinalExitHeading;
end
end

function [target, targetHeading] = updateReturnHomeStrategy(target, config, dt)
fp = config.fixedWing.finalPhase;
home = target.Payload.HomePosition(:);
targetHeading = computeExitHeading(target.Position, home);
target.Payload.NavigationLookaheadPoint = home;
distance = norm(home(1:2) - target.Position(1:2));

if distance <= fp.homeArrivalRadius
    target.Payload.FinalMissionCompleted = true;
    target.Payload.MissionComplete = true;
    target.Payload.LastNavigationEvent = "finalPhase:returnHomeComplete";
    heading = target.Payload.CurrentHeading;
    speed = max(config.fixedWing.minSpeed, target.Payload.FinalCruiseSpeed * 0.8);
    target.Payload.DesiredVelocity = [cos(heading) * speed; sin(heading) * speed; 0];
    target.Payload.SmoothedDesiredSpeed = speed;
end
end

function [target, targetHeading] = updateLoiterEndStrategy(target, config, dt)
fp = config.fixedWing.finalPhase;
allowExitArea = isfield(config.fixedWing, 'allowExitArea') && config.fixedWing.allowExitArea;
state = string(target.State);

if state ~= "LoiterEnd"
    targetHeading = target.Payload.TargetHeading;
    return;
end

radius = max(target.Payload.LoiterEndRadius, 1);
speed = target.Payload.FinalCruiseSpeed;
target.Payload.LoiterEndAngle = target.Payload.LoiterEndAngle + ...
    speed / radius * target.Payload.LoiterEndDirection * dt;
target.Payload.LoiterEndLoopProgress = target.Payload.LoiterEndLoopProgress + ...
    speed / radius * dt;

center = target.Payload.LoiterEndCenter(:);
targetPoint = center + radius * [cos(target.Payload.LoiterEndAngle); ...
    sin(target.Payload.LoiterEndAngle); 0];
target.Payload.NavigationLookaheadPoint = targetPoint;
targetHeading = computeExitHeading(target.Position, targetPoint);

if target.Payload.LoiterEndLoopProgress >= 2 * pi
target.Payload.LoiterEndCompleted = true;
        followUp = string(fp.loiterEndFollowUpStrategy);
        if followUp == "ReturnHome"
            target = transitionFixedWingState(target, "ReturnHome", "finalPhase:loiterEndToReturn", config);
            targetHeading = computeExitHeading(target.Position, target.Payload.HomePosition(:));
        elseif followUp == "NewRoute" || ~allowExitArea
            target.Payload.FinalMissionCompleted = true;
            target = regenerateFixedWingMission(target, config);
            target.Payload.FinalPhaseStarted = false;
            target.Payload.FinalPhase = false;
            target.Payload.FinalMissionCompleted = false;
            target.Payload.LastNavigationEvent = "finalPhase:loiterEndNewRoute";
            targetHeading = target.Payload.CurrentHeading;
    else
        target = transitionFixedWingState(target, "ApproachExit", "finalPhase:loiterEndToExit", config);
        targetHeading = computeExitHeading(target.Position, target.Payload.ExitPoint(:));
    end
end
end

function target = applyFinalPhaseHeadingSmoothing(target, targetHeading, config, dt)
fp = config.fixedWing.finalPhase;
oldHeading = target.Payload.SmoothedHeading;
if isempty(oldHeading) || isnan(oldHeading)
    oldHeading = target.Payload.CurrentHeading;
end

headingError = wrapToPiLocal(targetHeading - oldHeading);
maxTurnRate = computeFixedWingMaxTurnRate(target, config);
maxDelta = maxTurnRate * dt;
limitedDelta = min(max(headingError, -maxDelta), maxDelta);
newHeading = wrapToPiLocal(oldHeading + limitedDelta);

target.Payload.SmoothedHeading = newHeading;
target.Payload.CurrentHeading = newHeading;
target.Payload.DesiredHeading = targetHeading;
target.Payload.TurnRate = limitedDelta / dt;
target.Payload.TurnSeverity = computeTurnSeverity(newHeading, targetHeading);
end

function target = applyFinalPhaseSpeedLock(target, config)
fp = config.fixedWing.finalPhase;
motion = config.fixedWing.motion;
baseSpeed = target.Payload.FinalCruiseSpeed;
tolerance = fp.speedTolerance;
currentSpeed = norm(target.Velocity(1:2));
if isnan(currentSpeed) || currentSpeed < 1e-6
    currentSpeed = baseSpeed;
end
lockedSpeed = min(max(currentSpeed, baseSpeed * (1 - tolerance)), baseSpeed * (1 + tolerance));
if ~isfield(target.Payload, 'SmoothedDesiredSpeed') || isempty(target.Payload.SmoothedDesiredSpeed)
    target.Payload.SmoothedDesiredSpeed = lockedSpeed;
end
alpha = config.fixedWing.motion.speedSmoothing;
speedDelta = lockedSpeed - target.Payload.SmoothedDesiredSpeed;
maxIncrease = 1.2;
maxDecrease = 1.8;
if isfield(motion, 'maxSpeedIncreaseRate')
    maxIncrease = motion.maxSpeedIncreaseRate;
end
if isfield(motion, 'maxSpeedDecreaseRate')
    maxDecrease = motion.maxSpeedDecreaseRate;
end
speedDelta = min(max(speedDelta, -maxDecrease), maxIncrease);
target.Payload.SmoothedDesiredSpeed = target.Payload.SmoothedDesiredSpeed + alpha * speedDelta;
target.Payload.SmoothedDesiredSpeed = min(max(target.Payload.SmoothedDesiredSpeed, ...
    config.fixedWing.minSpeed), config.fixedWing.maxSpeed);
end

function exited = hasExitedWorld(position, config)
worldSize = config.world.size;
margin = config.fixedWing.finalPhase.exitBoundaryMargin;
exited = position(1) < -margin || position(1) > worldSize(1) + margin || ...
    position(2) < -margin || position(2) > worldSize(2) + margin;
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
