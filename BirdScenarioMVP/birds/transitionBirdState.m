function bird = transitionBirdState(bird, nextState, scenario, config, reason)
% transitionBirdState - Выполнить переход состояния птицы и действия при входе.
arguments
    bird (1, 1) struct
    nextState (1, 1) string
    scenario (1, 1) struct
    config (1, 1) struct
    reason (1, 1) string
end

nextState = string(nextState);

if nextState == string(bird.State)
    bird.Payload.LastTransitionReason = reason;
    return;
end

if ~isBirdStateTransitionAllowed(bird.State, nextState)
    error('transitionBirdState:InvalidTransition', ...
        'Transition from %s to %s is not allowed.', string(bird.State), nextState);
end

oldState = string(bird.State);
bird.Payload.LastState = oldState;
bird.Payload.NextState = nextState;
bird.State = nextState;
bird.TimeInState = 0;
bird.Payload.StateEntryTime = bird.CurrentTime;
bird.Payload.TransitionCount = bird.Payload.TransitionCount + 1;
bird.Payload.LastTransitionReason = reason;

trees = scenario.Trees;
motion = config.birds.motion;
worldZMax = config.world.size(3);

switch nextState
    case "Takeoff"
        bird = resetCruiseCurveFields(bird);
        bird = resetLandingFields(bird);
        bird.Visible = true;
        bird.Velocity = zeros(3, 1);
        bird.Acceleration = zeros(3, 1);
        if isfield(config.birds, 'realism') && config.birds.realism.enabled
            bird.Payload.TargetTreeID = selectRealisticTargetTree(bird, trees, config);
        else
            bird.Payload.TargetTreeID = selectTargetTree(bird, trees);
        end
        treeIdx = find([trees.ID] == bird.Payload.TargetTreeID, 1);
        bird.Payload.TargetTreePosition = trees(treeIdx).TopPosition;
        bird = applyBehaviorProfile(bird, config);

        gain = motion.takeoffAltitudeGainRange(1) + ...
            rand() * (motion.takeoffAltitudeGainRange(2) - motion.takeoffAltitudeGainRange(1));
        bird.Payload.TakeoffTargetAltitude = min(bird.Position(3) + gain, worldZMax);
        bird.Payload.DesiredSpeed = motion.takeoffSpeedRange(1) + ...
            rand() * (motion.takeoffSpeedRange(2) - motion.takeoffSpeedRange(1));
        bird.Payload.DesiredAltitude = bird.Payload.TakeoffTargetAltitude;
        bird.Payload.ArrivedToTargetTree = false;
        bird.Payload.DesiredVelocity = zeros(3, 1);
        bird.Payload.FlightDirection = zeros(3, 1);
        bird.Payload.PreviousDistanceToTargetTree = [];
        bird.Payload.NoProgressTime = 0;
        bird.Payload.BestDistanceToTargetTree = [];
        bird.Payload.ForceDirectToTarget = false;
        bird.Payload.SequentialFlyByCount = 0;

    case "Cruise"
        bird.Visible = true;
        bird = applyBehaviorProfile(bird, config);
        bird.Payload.PreviousDistanceToTargetTree = [];
        bird.Payload.NoProgressTime = 0;
        bird.Payload.BestDistanceToTargetTree = [];
        bird.Payload.ForceDirectToTarget = false;
        bird.Payload.DesiredSpeed = motion.cruiseSpeedRange(1) + ...
            rand() * (motion.cruiseSpeedRange(2) - motion.cruiseSpeedRange(1));
        bird.Payload.DesiredAltitude = motion.cruiseAltitudeRange(1) + ...
            rand() * (motion.cruiseAltitudeRange(2) - motion.cruiseAltitudeRange(1));
        if isfield(config.birds, 'curvedCruise') && config.birds.curvedCruise.enabled
            bird = initializeCruiseCurve(bird, config);
        end

    case "Landing"
        bird.Payload.CircleBeforeLanding = false;
        bird.Payload.CircleCenter = [];
        bird.Payload.CircleRadius = 0;
        bird.Payload.CircleEndTime = [];
        bird.Payload.ForceDirectToTarget = false;
        bird.Payload.NoProgressTime = 0;
        bird.Payload.IsSharpManeuverActive = false;
        bird.Payload.SequentialFlyByCount = 0;
        bird = initializeBirdLanding(bird, scenario, config);

    case "Hidden"
        bird = resetCruiseCurveFields(bird);
        bird.Payload.IsSharpManeuverActive = false;
        bird.Payload.SharpManeuverEndTime = [];
        bird.Payload.CircleBeforeLanding = false;
        if isfield(config.birds, 'realism') && config.birds.realism.enabled && ...
                rand() < config.birds.realism.randomPauseInPerchedProbability
            hiddenRange = config.birds.hiddenTimeRange;
            bird.Payload.HiddenDuration = hiddenRange(2) + ...
                rand() * (hiddenRange(2) - hiddenRange(1));
            bird.Payload.HiddenExtended = true;
            bird.Payload.LastRealismEvent = "extendedHidden";
        else
            bird.Payload.HiddenExtended = false;
        end
        if ~isempty(bird.Payload.LandingTargetPoint)
            bird.Position = bird.Payload.LandingTargetPoint(:);
            bird.Payload.LastCrownPoint = bird.Position;
        end
        if ~isempty(bird.Payload.TargetTreeID)
            treeIdx = find([trees.ID] == bird.Payload.TargetTreeID, 1);
            tree = trees(treeIdx);
            bird.Payload.CurrentTreeID = bird.Payload.TargetTreeID;
            bird.Payload.CurrentTreePosition = tree.TopPosition;
            bird.Payload.TargetTreeID = [];
            bird.Payload.TargetTreePosition = [];
        end
        bird.Visible = false;
        bird.Velocity = zeros(3, 1);
        bird.Acceleration = zeros(3, 1);
        bird.Payload.DesiredSpeed = 0;
        bird.Payload.DesiredVelocity = zeros(3, 1);
        bird.Payload.ArrivedToTargetTree = false;
        bird.Payload.LandingComplete = true;

    case "Perched"
        bird = resetCruiseCurveFields(bird);
        bird = resetLandingFields(bird);
        bird.Visible = false;
        bird.Velocity = zeros(3, 1);
        bird.Acceleration = zeros(3, 1);
        bird.Payload.DesiredSpeed = 0;
        bird.Payload.DesiredVelocity = zeros(3, 1);
end
end
