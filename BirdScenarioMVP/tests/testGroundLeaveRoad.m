% testGroundLeaveRoad - Checks temporary off-road excursion setup (ТЗ-08A).
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

assert(vehicle.State == "LeaveRoad", 'Vehicle must enter LeaveRoad state.');
assert(~isempty(vehicle.Payload.OffroadTarget), 'OffroadTarget must be set.');
offroadDistance = norm(vehicle.Payload.OffroadTarget(1:2) - vehicle.Position(1:2));
assert(offroadDistance >= config.groundVehicle.offroadDistanceRange(1) * 0.5, ...
    'Offroad target must be away from current road position.');
assert(vehicle.Payload.OffroadDistance >= config.groundVehicle.offroadDistanceRange(1) && ...
    vehicle.Payload.OffroadDistance <= config.groundVehicle.offroadDistanceRange(2), ...
    'OffroadDistance must be within configured range.');

disp('testGroundLeaveRoad passed.');
