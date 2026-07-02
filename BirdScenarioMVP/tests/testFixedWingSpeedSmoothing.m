% testFixedWingSpeedSmoothing - Checks speed smoothing and limits (ТЗ-09B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 100;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

speeds = vecnorm(uav.History.Velocity, 2, 2);
speedDelta = abs(diff(speeds));
assert(all(speeds >= config.fixedWing.minSpeed - 0.5), 'Speed below minSpeed.');
assert(all(speeds <= config.fixedWing.maxSpeed + 0.5), 'Speed above maxSpeed.');
assert(max(speedDelta) <= config.fixedWing.maxAcceleration * config.sim.dt + 1.0, ...
    'Speed changes too abruptly.');
assert(all(uav.History.DesiredSpeed >= config.fixedWing.minSpeed - 0.5), ...
    'DesiredSpeed below minSpeed.');

disp('testFixedWingSpeedSmoothing passed.');
