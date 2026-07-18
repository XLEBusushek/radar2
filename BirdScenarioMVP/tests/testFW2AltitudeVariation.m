% testFW2AltitudeVariation - TargetFlightLevel и высота меняются со временем (ТЗ-09S).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 2;
config.fixedWing.count = 0;
config.fixedWing2.altitudeProfile.levelChangeProbability = 0.5;
config.fixedWing2.altitudeProfile.levelChangeIntervalRange = [10, 20];
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 200;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(88);

[scenario, ~] = runSimulation(config);
uavs = getScenarioFixedWingUAVs(scenario);

for i = 1:numel(uavs)
    u = uavs(i);
    targetLevels = u.History.TargetFlightLevel;
    altitudes = u.History.Position(:, 3);
    assert(numel(unique(targetLevels)) >= 2, 'TargetFlightLevel should change.');
    assert(std(altitudes) > 5, 'Altitude should not be constant.');
end

disp('testFW2AltitudeVariation passed.');
