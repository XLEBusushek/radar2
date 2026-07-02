% testGroundVehicleFollowsRoad - Checks route-following road deviation (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 2;
config.groundVehicle.fsm.drive.stopProbability = 0;
config.groundVehicle.fsm.drive.leaveRoadProbability = 0;
config.sim.duration = 80;
config.sim.dt = 1;
rng(config.sim.seed);

[scenario, ~] = runSimulation(config);
vehicles = getScenarioGroundVehicles(scenario);
for i = 1:numel(vehicles)
    deviations = vehicles(i).History.RoadDeviation;
    deviations = deviations(isfinite(deviations));
    assert(mean(deviations < config.groundVehicle.roadDeviationTolerance * 2) >= 0.9, ...
        'Vehicle must follow road most of the time.');
    progress = vehicles(i).History.RouteProgress;
    assert(progress(end) > progress(1), 'Route progress must increase.');
end

disp('testGroundVehicleFollowsRoad passed.');
