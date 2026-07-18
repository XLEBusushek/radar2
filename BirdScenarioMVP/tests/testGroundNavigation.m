% testGroundNavigation - Проверяет обновление навигации по waypoint (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 1;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);
vehicle = transitionGroundState(vehicle, "Drive", "test", config);
vehicle = updateGroundNavigation(vehicle, scenario, config, config.sim.dt);

assert(vehicle.State == "Drive", 'Vehicle should remain in Drive.');
assert(isfinite(vehicle.Payload.DistanceToWaypoint), 'DistanceToWaypoint must be finite.');
assert(isfinite(vehicle.Payload.RoadDeviation), 'RoadDeviation must be finite.');
assert(vehicle.Payload.CurrentRoadID > 0, 'CurrentRoadID must be set.');

vehicle.Position = vehicle.Payload.CurrentWaypoint(:);
oldIndex = vehicle.Payload.CurrentWaypointIndex;
vehicle = updateGroundNavigation(vehicle, scenario, config, config.sim.dt);
assert(vehicle.Payload.CurrentWaypointIndex >= oldIndex, 'Waypoint index must not move backwards.');

disp('testGroundNavigation passed.');
