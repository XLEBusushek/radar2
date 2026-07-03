% testFW2SpeedSmoothness - Speed changes respect max rate (ТЗ-09S).
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
config.sim.duration = 90;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(55);

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

sp = config.fixedWing2.speedProfile;
fw2 = config.fixedWing2;
maxDelta = sp.maxSpeedChangeRate * config.sim.dt + 0.15;
speeds = uav.History.CurrentSpeed;

for k = 2:numel(speeds)
    assert(abs(speeds(k) - speeds(k - 1)) <= maxDelta, 'Speed jump too large.');
end
assert(all(speeds >= fw2.speed.minSpeed - 0.1), 'Speed below minSpeed.');
assert(all(speeds <= fw2.speed.maxSpeed + 0.1), 'Speed above maxSpeed.');

disp('testFW2SpeedSmoothness passed.');
