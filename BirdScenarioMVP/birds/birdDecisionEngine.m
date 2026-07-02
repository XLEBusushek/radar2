function [nextState, reason] = birdDecisionEngine(bird, scenario, config)
% birdDecisionEngine - Decide next bird state using probabilistic FSM rules.
arguments
    bird (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
end

currentState = string(bird.State);
stateConfig = getBirdFSMConfig(currentState, config);

if currentState == "Cruise" && isfield(config.birds, 'motion')
    if isfield(bird.Payload, 'BlockLandingThisStep') && bird.Payload.BlockLandingThisStep
        nextState = currentState;
        reason = "flyBy";
        return;
    end

    if isfield(bird.Payload, 'CircleBeforeLanding') && bird.Payload.CircleBeforeLanding && ...
            isfield(bird.Payload, 'CircleEndTime') && ~isempty(bird.Payload.CircleEndTime) && ...
            bird.CurrentTime < bird.Payload.CircleEndTime
        nextState = currentState;
        reason = "circleBeforeLanding";
        return;
    end

    if isCloseToTargetTreeForLanding(bird, config)
        nextState = "Landing";
        reason = "arrivalRadius";
        return;
    end
end

if currentState == "Hidden" && isfield(config.birds, 'realism') && ...
        config.birds.realism.enabled && isfield(bird.Payload, 'HiddenExtended') && ...
        bird.Payload.HiddenExtended && isfield(bird.Payload, 'HiddenDuration')
    if bird.TimeInState < bird.Payload.HiddenDuration
        nextState = currentState;
        reason = "extendedHidden";
        return;
    end
end

if bird.TimeInState < stateConfig.minTime
    nextState = currentState;
    reason = "minTimeNotReached";
    return;
end

if bird.TimeInState >= stateConfig.maxTime
    if currentState == "Cruise" && isfield(config.birds, 'landing') && ...
            config.birds.landing.enabled && ~isCloseToTargetTreeForLanding(bird, config)
        nextState = currentState;
        reason = "stay";
        return;
    end
    nextState = stateConfig.nextState;
    reason = "maxTime";
    return;
end

if rand() < stateConfig.probability
    if currentState == "Cruise"
        if isfield(bird.Payload, 'BlockLandingThisStep') && bird.Payload.BlockLandingThisStep
            nextState = currentState;
            reason = "flyBy";
            return;
        end
        if isfield(bird.Payload, 'CircleBeforeLanding') && bird.Payload.CircleBeforeLanding && ...
                isfield(bird.Payload, 'CircleEndTime') && ~isempty(bird.Payload.CircleEndTime) && ...
                bird.CurrentTime < bird.Payload.CircleEndTime
            nextState = currentState;
            reason = "circleBeforeLanding";
            return;
        end
    end
    if currentState == "Cruise" && isfield(config.birds, 'landing') && ...
            config.birds.landing.enabled && ~isCloseToTargetTreeForLanding(bird, config)
        nextState = currentState;
        reason = "stay";
        return;
    end
    nextState = stateConfig.nextState;
    reason = "probability";
    return;
end

if currentState == "Cruise"
    nextState = currentState;
    reason = "stay";
    return;
end

if currentState == "Landing"
  landingEnabled = isfield(config.birds, 'landing') && config.birds.landing.enabled;

  if isfield(bird.Payload, 'LandingComplete') && bird.Payload.LandingComplete
    nextState = "Hidden";
    reason = "landingComplete";
    return;
  end

  if landingEnabled && isBirdLandingComplete(bird, config)
    nextState = "Hidden";
    reason = "landingComplete";
    return;
  end

  if bird.TimeInState >= stateConfig.maxTime
    if ~landingEnabled
      nextState = "Hidden";
      reason = "maxTime";
      return;
    end
  end

  if rand() < stateConfig.probability
    if landingEnabled && ~isempty(bird.Payload.LandingTargetPoint)
      landingDist = norm(bird.Payload.LandingTargetPoint(:) - bird.Position(:));
      if landingDist <= config.birds.landing.finalRadius
        nextState = "Hidden";
        reason = "probability";
        return;
      end
    elseif ~landingEnabled
      nextState = "Hidden";
      reason = "probability";
      return;
    end
  end

  nextState = currentState;
  reason = "stay";
  return;
end

if bird.TimeInState >= stateConfig.maxTime
    nextState = stateConfig.nextState;
    reason = "maxTime";
    return;
end

if rand() < stateConfig.probability
    nextState = stateConfig.nextState;
    reason = "probability";
    return;
end

nextState = currentState;
reason = "stay";
end
