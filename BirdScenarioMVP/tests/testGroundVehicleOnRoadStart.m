% testGroundVehicleOnRoadStart - Проверяет старт наземного транспорта на дорогах (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 4;
rng(config.sim.seed);

scenario = initializeScenario(config);
vehicles = getScenarioGroundVehicles(scenario);
for i = 1:numel(vehicles)
    nearest = findNearestRoadPoint(vehicles(i).Position(:), scenario.RoadNetwork);
    assert(nearest.Distance < 2, 'Ground vehicle must start on road.');
    assert(vehicles(i).Payload.RoadDeviation < 2, 'Initial RoadDeviation must be small.');
end

disp('testGroundVehicleOnRoadStart passed.');
