function target = transitionFixedWingState(target, nextState, reason, config)
% transitionFixedWingState - Apply fixed-wing FSM transition entry actions.
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

fw = config.fixedWing;
allowExitArea = isfield(fw, 'allowExitArea') && fw.allowExitArea;
if ~allowExitArea && ismember(nextState, ["ExitArea", "ApproachExit", "AlignExit", "Exit"])
    return;
end

if ~isFixedWingTransitionAllowed(currentState, nextState, allowExitArea) && ...
        ~startsWith(string(reason), "finalPhase") && ...
        ~startsWith(string(reason), "boundaryRecovery") && ...
        string(reason) ~= "newRoute"
    error('transitionFixedWingState:InvalidTransition', ...
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
    case "Cruise"
        target.Payload.DesiredSpeed = sampleRange(fw.cruiseSpeedRange);
        target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.LastNavigationEvent = "cruise";
    case "Turn"
        target.Payload.DesiredSpeed = max(target.Payload.DesiredSpeed, fw.minSpeed);
        target.Payload.LastNavigationEvent = "turn";
    case "Climb"
        target = shiftFlightLevel(target, config, 1);
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.DesiredSpeed = max(target.Payload.DesiredSpeed, fw.minSpeed);
        target.Payload.LastNavigationEvent = "climb";
    case "Descend"
        target = shiftFlightLevel(target, config, -1);
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.DesiredSpeed = max(target.Payload.DesiredSpeed, fw.minSpeed);
        target.Payload.LastNavigationEvent = "descend";
    case "Loiter"
        target = initializeLoiter(target, fw);
    case "Dive"
        target = initializeDive(target, fw);
    case "Recover"
        target = selectNearestNormalFlightLevel(target, config);
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.DesiredSpeed = max(mean(fw.cruiseSpeedRange), fw.minSpeed);
        target.Payload.LastNavigationEvent = "recover";
    case "Return"
        target.Payload.CurrentWaypoint = target.Payload.HomePosition(:);
        target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.DesiredSpeed = max(mean(fw.cruiseSpeedRange), fw.minSpeed);
        target.Payload.ReturnUrgency = min(target.Payload.ReturnUrgency + 0.25, 1);
        target.Payload.LastNavigationEvent = "returnHome";
    case "ExitArea"
        target.Payload.CurrentWaypoint = target.Payload.ExitPoint(:);
        target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.DesiredSpeed = max(mean(fw.cruiseSpeedRange), fw.minSpeed);
        target.Payload.MissionComplete = true;
        target.Payload.LastNavigationEvent = "exitArea";
    case "ApproachExit"
        target.Payload.NavigationLookaheadPoint = target.Payload.ExitPoint(:);
        target.Payload.DesiredSpeed = target.Payload.FinalCruiseSpeed;
        target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.LastNavigationEvent = "approachExit";
    case "AlignExit"
        exitHeading = computeExitHeading(target.Position, target.Payload.ExitPoint(:));
        target.Payload.FinalExitHeading = exitHeading;
        target.Payload.TargetHeading = exitHeading;
        target.Payload.DesiredHeading = exitHeading;
        target.Payload.DesiredSpeed = target.Payload.FinalCruiseSpeed;
        target.Payload.LastNavigationEvent = "alignExit";
    case "Exit"
        if isempty(target.Payload.FinalExitHeading) || isnan(target.Payload.FinalExitHeading)
            target.Payload.FinalExitHeading = computeExitHeading(target.Position, target.Payload.ExitPoint(:));
        end
        target.Payload.TargetHeading = target.Payload.FinalExitHeading;
        target.Payload.DesiredHeading = target.Payload.FinalExitHeading;
        target.Payload.DesiredSpeed = target.Payload.FinalCruiseSpeed;
        target.Payload.LastNavigationEvent = "exit";
    case "LoiterEnd"
        target.Payload.DesiredSpeed = target.Payload.FinalCruiseSpeed;
        target.Payload.LastNavigationEvent = "loiterEnd";
    case "ReturnHome"
        target.Payload.TargetFlightLevel = target.Payload.FlightLevel;
        target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
        target.Payload.DesiredSpeed = target.Payload.FinalCruiseSpeed;
        target.Payload.LastNavigationEvent = "returnHomeFinal";
end
end

function allowed = isFixedWingTransitionAllowed(currentState, nextState, allowExitArea)
if nargin < 3
    allowExitArea = false;
end
finalStates = ["ApproachExit", "AlignExit", "Exit", "LoiterEnd", "ReturnHome"];

if ismember(currentState, finalStates)
    switch currentState
        case "ApproachExit"
            allowed = ismember(nextState, ["ApproachExit", "AlignExit", "Exit"]);
        case "AlignExit"
            allowed = ismember(nextState, ["AlignExit", "Exit"]);
        case "Exit"
            allowed = nextState == "Exit";
        case "LoiterEnd"
            allowed = ismember(nextState, ["LoiterEnd", "ApproachExit", "ReturnHome"]);
        case "ReturnHome"
            allowed = nextState == "ReturnHome";
        otherwise
            allowed = false;
    end
    return;
end

if ismember(nextState, finalStates)
    allowed = false;
    return;
end

terminal = currentState == "ExitArea";
if terminal
    allowed = nextState == "ExitArea";
    return;
end

switch currentState
    case "Cruise"
        allowed = ismember(nextState, ["Turn", "Climb", "Descend", "Loiter", "Dive", "Return"]);
    case "Turn"
        allowed = ismember(nextState, ["Cruise", "Climb", "Descend", "Loiter", "Return"]);
    case "Climb"
        allowed = ismember(nextState, ["Cruise", "Turn", "Loiter", "Return"]);
    case "Descend"
        allowed = ismember(nextState, ["Cruise", "Turn", "Loiter", "Dive", "Return"]);
    case "Loiter"
        allowed = ismember(nextState, ["Cruise", "Dive", "Return"]);
    case "Dive"
        allowed = nextState == "Recover";
    case "Recover"
        allowed = ismember(nextState, ["Cruise", "Return"]);
    case "Return"
        allowed = ismember(nextState, ["Cruise"]);
    otherwise
        allowed = true;
end

if allowExitArea
    switch currentState
        case "Cruise"
            allowed = allowed || nextState == "ExitArea";
        case "Turn"
            allowed = allowed || nextState == "ExitArea";
        case "Climb"
            allowed = allowed || nextState == "ExitArea";
        case "Descend"
            allowed = allowed || nextState == "ExitArea";
        case "Loiter"
            allowed = allowed || nextState == "ExitArea";
        case "Recover"
            allowed = allowed || nextState == "ExitArea";
        case "Return"
            allowed = allowed || nextState == "ExitArea";
    end
end
end

function target = initializeLoiter(target, fw)
range = fw.loiterRadiusRange;
target.Payload.LoiterRadius = sampleRange(range);
target.Payload.LoiterDirection = 1;
if rand() < 0.5
    target.Payload.LoiterDirection = -1;
end
heading = target.Payload.CurrentHeading;
radial = [cos(heading - target.Payload.LoiterDirection * pi / 2); ...
    sin(heading - target.Payload.LoiterDirection * pi / 2); 0];
target.Payload.LoiterCenter = target.Position(:) - target.Payload.LoiterRadius * radial;
target.Payload.LoiterStartTime = target.CurrentTime;
target.Payload.LoiterDuration = sampleRange(fw.loiterTimeRange);
target.Payload.LoiterAngle = atan2(target.Position(2) - target.Payload.LoiterCenter(2), ...
    target.Position(1) - target.Payload.LoiterCenter(1));
target.Payload.DesiredSpeed = max(mean(fw.cruiseSpeedRange), fw.minSpeed);
target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
target.Payload.LastNavigationEvent = "loiter";
end

function target = initializeDive(target, fw)
target.Payload.DiveStartAltitude = target.Position(3);
loss = sampleRange(fw.diveAltitudeLossRange);
target.Payload.DiveTargetAltitude = max(fw.operatingAltitudeRange(1), ...
    min(target.Position(3) - 10, target.Position(3) - loss));
target.Payload.DiveStartTime = target.CurrentTime;
target.Payload.DiveDuration = sampleRange(fw.diveDurationRange);
target.Payload.TargetFlightLevel = target.Payload.DiveTargetAltitude;
target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
target.Payload.DesiredSpeed = min(fw.maxSpeed, max(norm(target.Velocity), fw.minSpeed) + 3 + rand() * 5);
target.Payload.LastNavigationEvent = "dive";
end

function target = shiftFlightLevel(target, config, direction)
levels = config.fixedWing.flightLevel.levelRange(1):config.fixedWing.flightLevel.levelSpacing: ...
    config.fixedWing.flightLevel.levelRange(2);
if isempty(levels)
    return;
end
idx = target.Payload.FlightLevelIndex;
if isempty(idx) || idx < 1 || idx > numel(levels)
    [~, idx] = min(abs(levels - target.Payload.TargetFlightLevel));
end
idx = min(max(idx + sign(direction), 1), numel(levels));
target.Payload.FlightLevelIndex = idx;
target.Payload.FlightLevel = levels(idx);
target.Payload.TargetFlightLevel = levels(idx);
tol = config.fixedWing.flightLevel.altitudeTolerance;
target.Payload.AltitudeBand = [levels(idx) - tol, levels(idx) + tol];
end

function target = selectNearestNormalFlightLevel(target, config)
levels = config.fixedWing.flightLevel.levelRange(1):config.fixedWing.flightLevel.levelSpacing: ...
    config.fixedWing.flightLevel.levelRange(2);
if isempty(levels)
    return;
end
[~, idx] = min(abs(levels - target.Position(3)));
target.Payload.FlightLevelIndex = idx;
target.Payload.FlightLevel = levels(idx);
target.Payload.TargetFlightLevel = levels(idx);
tol = config.fixedWing.flightLevel.altitudeTolerance;
target.Payload.AltitudeBand = [levels(idx) - tol, levels(idx) + tol];
end

function value = sampleRange(range)
lo = min(range);
hi = max(range);
value = lo + rand() * max(0, hi - lo);
end

function value = clamp(value, lowerBound, upperBound)
value = min(max(value, lowerBound), upperBound);
end
