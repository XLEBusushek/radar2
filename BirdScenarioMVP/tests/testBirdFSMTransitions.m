% testBirdFSMTransitions - Проверяет полный цикл состояний FSM (ТЗ-05A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 120;
config.sim.dt = 1;
config.birds.landing.enabled = true;
config.birds.landing.approachRadius = 2000;

config.birds.fsm.enabled = true;
config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 3;
config.birds.fsm.perched.takeoffProbability = 1.0;

config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 3;
config.birds.fsm.takeoff.cruiseProbability = 1.0;

config.birds.fsm.cruise.minTime = 1;
config.birds.fsm.cruise.maxTime = 60;
config.birds.fsm.cruise.landingProbability = 0.0;

config.birds.fsm.landing.minTime = 1;
config.birds.fsm.landing.maxTime = 30;
config.birds.fsm.landing.hiddenProbability = 1.0;

config.birds.fsm.hidden.minTime = 1;
config.birds.fsm.hidden.maxTime = 3;
config.birds.fsm.hidden.perchedProbability = 1.0;

[scenario, ~] = runSimulation(config);

requiredStates = ["Perched", "Takeoff", "Cruise", "Landing", "Hidden"];

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));

    for s = 1:numel(requiredStates)
        assert(any(states == requiredStates(s)), ...
            'History must contain state: %s.', requiredStates(s));
    end

    assert(target.Payload.TransitionCount > 0, ...
        'TransitionCount must be greater than zero.');

    for j = 1:numel(states) - 1
        if states(j) ~= states(j + 1)
            assert(isBirdStateTransitionAllowed(states(j), states(j + 1)), ...
                'Forbidden transition: %s -> %s.', states(j), states(j + 1));
        end
    end
end

disp('testBirdFSMTransitions passed.');
