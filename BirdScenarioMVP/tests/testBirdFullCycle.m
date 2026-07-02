% testBirdFullCycle - Checks full tree-to-tree behavior cycle (ТЗ-05D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 300;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.birds.landing.enabled = true;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 3;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 3;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 8;
config.birds.fsm.cruise.maxTime = 30;
config.birds.fsm.cruise.landingProbability = 1.0;
config.birds.fsm.cruise.landingProbability = 0.0;
config.birds.fsm.landing.minTime = 2;
config.birds.fsm.landing.maxTime = 25;
config.birds.fsm.landing.hiddenProbability = 1.0;
config.birds.fsm.hidden.minTime = 1;
config.birds.fsm.hidden.maxTime = 3;
config.birds.fsm.hidden.perchedProbability = 1.0;

[scenario, ~] = runSimulation(config);

requiredStates = ["Perched", "Takeoff", "Cruise", "Landing", "Hidden"];
foundFullCycle = false;
foundSecondTakeoff = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));

    hasAllStates = true;
    for s = 1:numel(requiredStates)
        if ~any(states == requiredStates(s))
            hasAllStates = false;
            break;
        end
    end

    if ~hasAllStates
        continue;
    end

    assert(target.Payload.TransitionCount >= 5, ...
        'TransitionCount must be at least 5 for full cycle.');

    hiddenIdx = find(states == "Hidden", 1, 'last');
    perchedAfterHidden = find(states == "Perched" & (1:numel(states))' > hiddenIdx, 1);
    assert(~isempty(perchedAfterHidden), ...
        'Perched must follow Hidden in full cycle.');

    takeoffAfterPerched = find(states == "Takeoff" & (1:numel(states))' > perchedAfterHidden, 1);
    if ~isempty(takeoffAfterPerched)
        foundSecondTakeoff = true;
    end

    foundFullCycle = true;
end

assert(foundFullCycle, 'At least one bird must complete the full state cycle.');
assert(foundSecondTakeoff, 'At least one bird must start a second takeoff.');

disp('testBirdFullCycle passed.');
