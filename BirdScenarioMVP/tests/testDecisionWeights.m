% testDecisionWeights - Checks behavior action weights (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.realism.enabled = false;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
target = scenario.Targets(1);
target.CurrentTime = target.Behavior.NextDecisionTime;

context = getBehaviorContext(target, scenario, config);
actions = getAllowedBehaviorActions(target, context, config);
weights = evaluateBehaviorWeights(target, context, actions, config);

assert(numel(weights.ActionNames) == numel(actions), ...
    'Weights must exist for all allowed actions.');
assert(numel(weights.Values) == numel(actions), ...
    'Weight values must match action count.');
assert(all(weights.Values >= 0), 'Weights must not be negative.');
assert(sum(weights.Values) > 0, 'Normal context must have positive weight sum.');

cooldownAction = actions(1);
fieldName = matlab.lang.makeValidName(char(cooldownAction));
target.Behavior.Memory.Cooldowns.(fieldName) = context.Time + config.behavior.cooldownDefault;
weightsCooldown = evaluateBehaviorWeights(target, context, actions, config);
idx = find(weightsCooldown.ActionNames == cooldownAction, 1);
assert(weightsCooldown.Values(idx) == 0, 'Cooldown action weight must be zero.');

disp('testDecisionWeights passed.');
