% testFW2SpeedVariation - TargetSpeed и CurrentSpeed меняются со временем (ТЗ-09S).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 2;
config.fixedWing.count = 0;
config.fixedWing2.speedProfile.speedChangeProbability = 0.5;
config.fixedWing2.speedProfile.speedChangeIntervalRange = [10, 20];
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 120;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(77);

[scenario, ~] = runSimulation(config);
uavs = getScenarioFixedWingUAVs(scenario);

for i = 1:numel(uavs)
    u = uavs(i);
    targetSpeeds = u.History.TargetSpeed;
    currentSpeeds = u.History.CurrentSpeed;
    assert(numel(unique(round(targetSpeeds, 1))) >= 2, 'TargetSpeed should change.');
    assert(std(currentSpeeds) > 0.3, 'CurrentSpeed should not be constant.');
end

disp('testFW2SpeedVariation passed.');
