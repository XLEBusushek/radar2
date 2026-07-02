% testGroundInitialization - Checks ground vehicle creation (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 4;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
groundVehicles = getScenarioGroundVehicles(scenario);

assert(numel(groundVehicles) == config.groundVehicle.count, ...
    'Ground vehicle count must match config.');

rcsRange = config.groundVehicle.rcsRange;
for i = 1:numel(groundVehicles)
    vehicle = groundVehicles(i);
    assert(vehicle.Class == "ground", 'Class must be ground.');
    assert(vehicle.Subtype == "vehicle", 'Subtype must be vehicle.');
    assert(vehicle.Position(3) >= 0 && vehicle.Position(3) <= 3, 'Ground Z must be near zero.');
    assert(vehicle.RCS >= rcsRange(1) && vehicle.RCS <= rcsRange(2), 'RCS out of range.');
    assert(isfield(vehicle.Payload, 'DriverAggression'), 'DriverAggression required.');
    assert(isfield(vehicle.Payload, 'RoadDiscipline'), 'RoadDiscipline required.');
    assert(isfield(vehicle.Behavior.Personality, 'DriverAggression'), ...
        'Behavior personality must include DriverAggression.');
    validateTarget(vehicle, config);
end

disp('testGroundInitialization passed.');
