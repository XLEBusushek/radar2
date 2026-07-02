function target = updateBehaviorEngine(target, scenario, config, dt)
% updateBehaviorEngine - Universal probabilistic behavior decision loop.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double %#ok<INUSD>
end

if ~isfield(config, 'behavior') || ~config.behavior.enabled
    return;
end

if target.Class == "air" && target.Subtype == "fixedWingUAV" && ...
        isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted
    return;
end

if ~isfield(target, 'Behavior') || isempty(fieldnames(target.Behavior))
    target = initializeBehaviorProfile(target, config);
end

if ~target.Behavior.Enabled
    return;
end

if target.CurrentTime < target.Behavior.NextDecisionTime
    return;
end

context = getBehaviorContext(target, scenario, config);
actions = getAllowedBehaviorActions(target, context, config);
weights = evaluateBehaviorWeights(target, context, actions, config);
[action, reason] = selectBehaviorAction(weights, config, target);

target = applyBehaviorDecision(target, action, reason, scenario, config);
target = updateBehaviorMemory(target, action, reason, context, config);
target = appendBehaviorHistory(target, context, weights, action, reason);
end
