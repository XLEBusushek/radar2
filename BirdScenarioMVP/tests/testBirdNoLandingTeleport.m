% testBirdNoLandingTeleport - Проверяет отсутствие большого скачка Landing -> Hidden (ТЗ-05D).
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
config.birds.landing.approachRadius = 120;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 10;
config.birds.fsm.cruise.maxTime = 40;
config.birds.fsm.cruise.landingProbability = 1.0;
config.birds.fsm.cruise.landingProbability = 0.0;
config.birds.fsm.landing.minTime = 2;
config.birds.fsm.landing.maxTime = 30;
config.birds.fsm.landing.hiddenProbability = 0.0;

[scenario, ~] = runSimulation(config);

maxJump = config.birds.landing.touchdownDistance + 5;
foundTransition = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));
    positions = target.History.Position;

    for j = 1:numel(states) - 1
        if states(j) == "Landing" && states(j + 1) == "Hidden"
            foundTransition = true;
            jumpDistance = norm(positions(j + 1, :) - positions(j, :));
            assert(jumpDistance <= maxJump, ...
                'Landing to Hidden jump must be small (%.2f m > %.2f m).', ...
                jumpDistance, maxJump);
        end
    end
end

assert(foundTransition, 'Must find at least one Landing to Hidden transition.');

disp('testBirdNoLandingTeleport passed.');
