% testFixedWingBoundaryRecovery - Checks boundary recovery behavior (ТЗ-09D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 55;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.sim.dt = 1;
setScenarioRNG(55);

scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);
worldSize = config.world.size;
uav.Position = [worldSize(1) - 30; 1000; uav.Position(3)];
uav.Velocity = [config.fixedWing.minSpeed; 0; 0];
uav.Payload.CurrentHeading = 0;
uav.Payload.SmoothedHeading = 0;
uav = appendTargetHistory(uav);

initialDistance = inf;
for k = 1:40
    uav = updateTarget(uav, scenario, config, config.sim.dt);
    initialDistance = min(initialDistance, uav.Payload.DistanceToBoundary);
end

assert(any(uav.History.BoundaryRecoveryActive), 'BoundaryRecoveryActive must turn on near edge.');
recoveryIdx = find(uav.History.BoundaryRecoveryActive, 1, 'first');
recoveryTarget = uav.History.BoundaryRecoveryTarget(recoveryIdx, :);
assert(all(recoveryTarget(1:2) >= config.fixedWing.navigation.minWaypointBoundaryMargin), ...
    'Recovery target must lie inside waypoint margin.');
assert(uav.Payload.DistanceToBoundary > initialDistance + 20, ...
    'Distance to boundary should increase during recovery.');

disp('testFixedWingBoundaryRecovery passed.');
