% testFW2BoundaryRecovery - Восстановление в зоне предупреждения/критической зоне (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 1;
config.fixedWing.count = 0;
config.behavior.enabled = false;
setScenarioRNG(55);

scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

uav.Position = [config.world.size(1) - 150; 1000; uav.Position(3)];
uav.Velocity = [-config.fixedWing2.speed.minSpeed; 0; 0];
uav.Payload.CurrentHeading = pi;
uav.Payload.RecoveryPoint = [];
uav.Payload.BorderFollowingTime = 0;

initialDist = inf;
for k = 1:30
    uav = updateTarget(uav, scenario, config, config.sim.dt);
    initialDist = min(initialDist, uav.Payload.DistanceToBoundary);
end

assert(any(string(uav.History.State) == "BoundaryRecovery"), 'BoundaryRecovery must activate.');
assert(uav.Payload.DistanceToBoundary > initialDist + 10, 'Must move inward from boundary.');
safe = fw2_getZoneBounds(config).SafeZone;
if ~isempty(uav.Payload.RecoveryPoint)
    rp = uav.Payload.RecoveryPoint(:);
    assert(rp(1) >= safe(1) && rp(1) <= safe(2), 'Recovery X inside safe zone.');
end

disp('testFW2BoundaryRecovery passed.');
