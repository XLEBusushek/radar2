% testBirdCircleBeforeLanding - Checks circle-before-landing behavior (ТЗ-05E).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 180;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.birds.landing.enabled = true;
config.birds.realism.enabled = true;
config.birds.realism.circleBeforeLandingProbability = 1.0;
config.birds.realism.retargetProbability = 0.0;
config.birds.realism.flyByProbability = 0.0;
config.birds.realism.sharpManeuverProbability = 0.0;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 5;
config.birds.fsm.cruise.maxTime = 120;
config.birds.fsm.cruise.landingProbability = 0.0;
config.birds.fsm.landing.minTime = 2;
config.birds.fsm.landing.maxTime = 25;
config.birds.fsm.landing.hiddenProbability = 1.0;
config.birds.fsm.hidden.minTime = 1;
config.birds.fsm.hidden.maxTime = 3;
config.birds.fsm.hidden.perchedProbability = 0.0;

[scenario, ~] = runSimulation(config);

foundCircle = false;
foundLandingOrHidden = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;
    states = string(history.State(:));

    if any(history.CircleBeforeLanding)
        foundCircle = true;
    end

    if any(states == "Landing") || any(states == "Hidden")
        foundLandingOrHidden = true;
    end
end

assert(foundCircle, 'At least one bird must circle before landing.');
assert(foundLandingOrHidden, ...
    'At least one bird must reach Landing or Hidden after circling.');

disp('testBirdCircleBeforeLanding passed.');
