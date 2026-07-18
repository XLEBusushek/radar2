% testFW2NoBorderFollowing - Нет длительного полёта параллельно границе (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 1;
config.fixedWing.count = 0;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 180;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(88);

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

maxBorderTime = max(uav.History.BorderFollowingTime);
if isfield(uav.History, 'BorderFollowingTime')
    assert(maxBorderTime <= config.fixedWing2.boundary.maxBorderParallelTime + config.sim.dt + 1, ...
        'Border following too long.');
end
assert(any(string(uav.History.State) == "BoundaryRecovery") || maxBorderTime == 0, ...
    'Border following must trigger recovery or not occur.');

disp('testFW2NoBorderFollowing passed.');
