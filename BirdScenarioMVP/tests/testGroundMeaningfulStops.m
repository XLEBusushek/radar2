% testGroundMeaningfulStops - Проверяет семантику длительности остановок (ТЗ-08B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 1;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);
vehicle = transitionGroundState(vehicle, "Drive", "test", config);
vehicle.CurrentTime = 10;
vehicle = transitionGroundState(vehicle, "Stop", "testStop", config);

assert(vehicle.State == "Stop", 'Vehicle must enter Stop state.');
assert(vehicle.Payload.StopUntilTime > vehicle.CurrentTime, 'Stop must have a future end time.');
stopDuration = vehicle.Payload.StopUntilTime - vehicle.CurrentTime;
assert(stopDuration >= config.groundVehicle.stopDurationRange(1) && ...
    stopDuration <= config.groundVehicle.stopDurationRange(2), 'Stop duration out of range.');

vehicle.CurrentTime = vehicle.Payload.StopUntilTime - 0.1;
vehicle = updateGroundNavigation(vehicle, scenario, config, 1);
assert(vehicle.State == "Stop", 'Vehicle must not leave Stop before StopUntilTime.');

vehicle.CurrentTime = vehicle.Payload.StopUntilTime + 0.1;
vehicle = updateGroundNavigation(vehicle, scenario, config, 1);
assert(vehicle.State == "Drive", 'Vehicle must resume driving after StopUntilTime.');

disp('testGroundMeaningfulStops passed.');
