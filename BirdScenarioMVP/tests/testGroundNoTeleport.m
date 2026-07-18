% testGroundNoTeleport - Проверяет отсутствие нереалистичных скачков наземного транспорта (ТЗ-08B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 2;
config.groundVehicle.fsm.drive.leaveRoadProbability = 0;
config.sim.duration = 60;
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

[scenario, ~] = runSimulation(config);
vehicles = getScenarioGroundVehicles(scenario);

maxStep = 1.6 * config.groundVehicle.speedRange(2) * config.sim.dt + 5;
for i = 1:numel(vehicles)
    pos = vehicles(i).History.Position;
    stepDistance = vecnorm(diff(pos(:, 1:2), 1, 1), 2, 2);
    assert(all(stepDistance <= maxStep), 'Ground vehicle position jump is too large.');
end

disp('testGroundNoTeleport passed.');
