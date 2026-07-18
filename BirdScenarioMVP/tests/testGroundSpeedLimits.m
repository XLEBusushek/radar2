% testGroundSpeedLimits - Проверяет лимиты скорости и ускорения (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 1;
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);
vehicle = transitionGroundState(vehicle, "Drive", "test", config);

for k = 1:20
    vehicle = updateGroundNavigation(vehicle, scenario, config, config.sim.dt);
    vehicle.Payload.DesiredVelocity = computeGroundDesiredVelocity(vehicle, scenario, config);
    vehicle = updateGroundKinematics(vehicle, config, config.sim.dt);
    assert(norm(vehicle.Velocity) <= config.groundVehicle.speedRange(2) + 1e-6, ...
        'Ground speed exceeded max speed.');
    assert(norm(vehicle.Acceleration) <= config.groundVehicle.maxAcceleration + 1e-6, ...
        'Ground acceleration exceeded max acceleration.');
    assert(vehicle.Position(3) >= 0 && vehicle.Position(3) <= 3, ...
        'Ground vehicle height must remain near zero.');
end

disp('testGroundSpeedLimits passed.');
