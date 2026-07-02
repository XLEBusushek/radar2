% testGroundNoCornerCutting - Checks vehicles mostly stay on routes (ТЗ-08B).
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
config.groundVehicle.fsm.drive.stopProbability = 0;
config.groundVehicle.fsm.drive.leaveRoadProbability = 0;
config.groundVehicle.fsm.drive.turnAroundProbability = 0;
config.groundVehicle.fsm.drive.changeSpeedProbability = 0;
config.sim.duration = 80;
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

[scenario, ~] = runSimulation(config);
vehicles = getScenarioGroundVehicles(scenario);

for i = 1:numel(vehicles)
    h = vehicles(i).History;
    assert(isfield(h, 'RoadDeviation'), 'History must include RoadDeviation.');
    deviations = h.RoadDeviation(isfinite(h.RoadDeviation));
    assert(~isempty(deviations), 'RoadDeviation must be recorded.');
    onRouteRatio = mean(deviations <= 2 * config.groundVehicle.roadDeviationTolerance);
    assert(onRouteRatio >= 0.90, 'Vehicle spends too much time away from route.');
end

disp('testGroundNoCornerCutting passed.');
