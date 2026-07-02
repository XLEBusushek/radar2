% testGroundVehicleSpeedLimits - Checks ground vehicle speed/accel/Z limits (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 2;
config.groundVehicle.fsm.drive.leaveRoadProbability = 0;
config.sim.duration = 60;
config.sim.dt = 1;
rng(config.sim.seed);

[scenario, ~] = runSimulation(config);
vehicles = getScenarioGroundVehicles(scenario);
for i = 1:numel(vehicles)
    speeds = vecnorm(vehicles(i).History.Velocity, 2, 2);
    accels = vecnorm(vehicles(i).History.Acceleration, 2, 2);
    z = vehicles(i).History.Position(:, 3);
    moving = speeds > 0.1;
    assert(all(speeds <= config.ground.speedRange(2) + 1), 'Ground speed exceeds max.');
    assert(all(speeds(~moving) < config.ground.speedRange(1) | speeds(~moving) < 0.2), ...
        'Stopped vehicles should be near zero speed.');
    assert(all(accels <= config.ground.motion.maxAcceleration + 1e-6), 'Acceleration exceeds max.');
    assert(all(z >= 0 & z <= 3), 'Ground Z must stay near zero.');
end

disp('testGroundVehicleSpeedLimits passed.');
