% testGroundVehicleOffRoadReturn - Checks off-road excursion returns to route (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 1;
rng(config.sim.seed);

scenario = initializeScenario(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);
vehicle = transitionGroundState(vehicle, "Drive", "test", config);
vehicle = updateGroundNavigation(vehicle, scenario, config, config.sim.dt);
vehicle = leaveRoadTemporarily(vehicle, scenario.RoadNetwork, config);
vehicle = transitionGroundState(vehicle, "LeaveRoad", "testLeave", config);
assert(vehicle.Payload.IsOffRoad, 'Vehicle must be marked off-road.');

vehicle.Position = vehicle.Payload.OffRoadTarget(:);
vehicle = updateGroundNavigation(vehicle, scenario, config, config.sim.dt);
assert(vehicle.State == "ReturnRoad", 'Vehicle must transition to ReturnRoad.');
vehicle.Position = vehicle.Payload.ReturnRoadPoint(:);
vehicle = updateGroundNavigation(vehicle, scenario, config, config.sim.dt);
assert(vehicle.State == "Drive", 'Vehicle must return to Drive.');
assert(vehicle.Payload.RoadDeviation <= config.groundVehicle.roadDeviationTolerance, ...
    'Vehicle must return near road.');

disp('testGroundVehicleOffRoadReturn passed.');
