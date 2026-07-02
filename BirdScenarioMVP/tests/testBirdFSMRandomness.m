% testBirdFSMRandomness - Checks probabilistic FSM behavior (ТЗ-05A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 20;
config.sim.dt = 1;
config.birds.count = 20;
config.birds.fsm.enabled = true;

config.birds.fsm.perched.takeoffProbability = 0.2;
config.birds.fsm.takeoff.cruiseProbability = 0.3;
config.birds.fsm.cruise.landingProbability = 0.3;
config.birds.fsm.landing.hiddenProbability = 0.5;
config.birds.fsm.hidden.perchedProbability = 0.5;

[scenario, ~] = runSimulation(config);

stateSequences = strings(numel(scenario.Targets), 1);
anyLeftPerched = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    stateSequences(i) = strjoin(string(target.History.State(:)).', '|');

    if any(string(target.History.State(:)) ~= "Perched")
        anyLeftPerched = true;
    end
end

assert(numel(unique(stateSequences)) > 1, ...
    'Not all birds should have identical state histories.');
assert(anyLeftPerched, 'At least some birds should leave Perched.');

disp('testBirdFSMRandomness passed.');
