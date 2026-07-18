% testBirdSharpManeuver - Проверяет активацию и лимиты резкого манёвра (ТЗ-05E).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 60;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.birds.realism.enabled = true;
config.birds.realism.sharpManeuverProbability = 0.8;
config.birds.realism.retargetProbability = 0.0;
config.birds.realism.flyByProbability = 0.0;
config.birds.realism.circleBeforeLandingProbability = 0.0;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 5;
config.birds.fsm.cruise.maxTime = 50;
config.birds.fsm.cruise.landingProbability = 0.0;

[scenario, ~] = runSimulation(config);

maxSpeed = config.birds.motion.speedRange(2);
maxAccel = config.birds.motion.maxAcceleration;
tolerance = 1e-6;
foundSharp = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;

    if any(history.IsSharpManeuverActive)
        foundSharp = true;
    end

    speeds = vecnorm(history.Velocity, 2, 2);
    assert(all(speeds <= maxSpeed + tolerance), ...
        'Speed must not exceed configured maximum during sharp maneuvers.');
    accels = vecnorm(history.Acceleration, 2, 2);
    assert(all(accels <= maxAccel + tolerance), ...
        'Acceleration must not exceed configured maximum during sharp maneuvers.');
end

assert(foundSharp, 'At least one bird must perform a sharp maneuver.');

disp('testBirdSharpManeuver passed.');
