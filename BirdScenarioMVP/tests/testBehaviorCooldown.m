% testBehaviorCooldown - Checks action cooldown behavior (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.behavior.decisionPeriodRange = [0.5, 0.5];
config.behavior.cooldownDefault = 10;
config.birds.realism.enabled = false;
config.sim.duration = 20;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);

target = scenario.Targets(1);
memory = target.Behavior.Memory;
assert(memory.LastAction ~= "", 'LastAction must be set.');

fieldName = matlab.lang.makeValidName(char(memory.LastAction));
assert(isfield(memory.Cooldowns, fieldName), 'Selected action must get cooldown.');
assert(memory.Cooldowns.(fieldName) > memory.LastActionTime, ...
    'Cooldown end time must be after action time.');

recent = memory.RecentActions;
context = getBehaviorContext(target, scenario, config);
actions = getAllowedBehaviorActions(target, context, config);
if any(actions == memory.LastAction)
    weights = evaluateBehaviorWeights(target, context, actions, config);
    idx = find(weights.ActionNames == memory.LastAction, 1);
    assert(weights.Values(idx) == 0, 'Active cooldown must reduce selected action weight to zero.');
end

assert(numel(recent) <= config.behavior.recentActionMemoryLength, ...
    'RecentActions must respect memory length.');

disp('testBehaviorCooldown passed.');
