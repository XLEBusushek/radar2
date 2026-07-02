% testFixedWingLoiter - Checks fixed-wing loiter motion (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.fixedWing.loiterRadiusRange = [40, 40];
config.fixedWing.maxTurnRateDeg = 45;
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = transitionFixedWingState(uav(1), "Loiter", "test", config);
uav = appendTargetHistory(uav);
for k = 1:20
    uav = updateTarget(uav, scenario, config, config.sim.dt);
end

states = string(uav.History.State);
speeds = vecnorm(uav.History.Velocity, 2, 2);
xy = uav.History.Position(:, 1:2);
headingChanges = abs(diff(unwrap(atan2(diff(xy(:, 2)), diff(xy(:, 1))))));

assert(any(states == "Loiter"), 'Loiter state must occur.');
assert(any(headingChanges > deg2rad(3)), 'Loiter trajectory should curve.');
assert(all(speeds >= config.fixedWing.minSpeed - 0.5), 'Loiter speed below minSpeed.');

disp('testFixedWingLoiter passed.');
