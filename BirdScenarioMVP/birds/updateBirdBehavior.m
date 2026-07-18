function bird = updateBirdBehavior(bird, scenario, config, dt)
% updateBirdBehavior - Обновить поведенческое состояние птицы через вероятностный FSM.
if isfield(config, 'behavior') && isfield(config.behavior, 'enabled') && ...
        config.behavior.enabled
    bird = updateBehaviorEngine(bird, scenario, config, dt);
    bird = applyMandatoryTargetTransitions(bird, scenario, config);
    return;
end

if ~isfield(config, 'birds') || ~isfield(config.birds, 'fsm') || ...
        ~isfield(config.birds.fsm, 'enabled') || ~config.birds.fsm.enabled
    return;
end

if isfield(config.birds, 'realism') && config.birds.realism.enabled && ...
        string(bird.State) == "Cruise"
    bird = applyBirdRealismEvents(bird, scenario, config);
end

[nextState, reason] = birdDecisionEngine(bird, scenario, config);

if ~isBirdStateTransitionAllowed(bird.State, nextState)
    error('updateBirdBehavior:InvalidTransition', ...
        'Transition from %s to %s is not allowed.', string(bird.State), string(nextState));
end

bird = transitionBirdState(bird, nextState, scenario, config, reason);
end
