% testGroundPurePursuitRoute - Проверяет диагностику pure pursuit по маршруту (ТЗ-08B).
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
config.groundVehicle.fsm.drive.stopProbability = 0;
config.groundVehicle.fsm.drive.leaveRoadProbability = 0;
config.sim.duration = 50;
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

[scenario, ~] = runSimulation(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);

progress = vehicle.History.RouteProgress;
progress = progress(isfinite(progress));
assert(all(diff(progress) >= -1e-6), 'RouteProgress must be monotonic.');

lookahead = vehicle.History.LookaheadPoint;
for i = 1:size(lookahead, 1)
    if any(isnan(lookahead(i, :)))
        continue;
    end
    projection = projectGroundRoute(lookahead(i, :).', vehicle.Payload.Route, 0);
    assert(projection.DistanceToRoute < 1e-6, 'LookaheadPoint must lie on route.');
end

disp('testGroundPurePursuitRoute passed.');
