% testGroundReturnRoad - Checks return-to-road target selection (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 1;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);
vehicle = transitionGroundState(vehicle, "Drive", "test", config);
vehicle = leaveRoadTemporarily(vehicle, scenario.RoadNetwork, config);
vehicle = transitionGroundState(vehicle, "LeaveRoad", "test", config);
vehicle.Position = vehicle.Payload.OffroadTarget(:);
vehicle = returnToRoad(vehicle, scenario.RoadNetwork);
vehicle = transitionGroundState(vehicle, "ReturnRoad", "test", config);

assert(vehicle.State == "ReturnRoad", 'Vehicle must enter ReturnRoad state.');
assert(~isempty(vehicle.Payload.ReturnRoadPoint), 'ReturnRoadPoint must be set.');
nearest = findNearestRoad(vehicle.Payload.ReturnRoadPoint(:), scenario.RoadNetwork);
assert(nearest.Distance < 1e-6, 'ReturnRoadPoint must lie on a road.');
assert(vehicle.Payload.CurrentRoadID > 0, 'CurrentRoadID must be set during return.');

disp('testGroundReturnRoad passed.');
