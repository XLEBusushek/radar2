% testFixedWingCruise - Checks cruise motion toward waypoint (ТЗ-09A).
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
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.sim.duration = 20;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

speeds = vecnorm(uav.History.Velocity, 2, 2);
assert(max(vecnorm(diff(uav.History.Position), 2, 2)) > 0, 'Fixed-wing UAV must move.');
assert(all(speeds >= config.fixedWing.minSpeed - 0.5), 'Fixed-wing UAV must not hover.');
assert(any(uav.History.DistanceToWaypoint < uav.History.DistanceToWaypoint(1)), ...
    'Distance to waypoint should decrease during cruise.');

disp('testFixedWingCruise passed.');
