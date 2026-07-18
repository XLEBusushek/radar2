% testFW2AltitudeLevels - Лимиты высоты и набора (ТЗ-09R).
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
config.sim.duration = 120;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(42);

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);
fw2 = config.fixedWing2;
ap = fw2.altitudeProfile;

altitudes = uav.History.Position(:, 3);
assert(all(altitudes >= ap.levelRange(1) - 10), 'Altitude too low.');
assert(all(altitudes <= ap.levelRange(2) + 10), 'Altitude too high.');
assert(all(abs(uav.History.ClimbAngleDeg) <= ap.maxClimbAngleDeg + 2), ...
    'Climb angle exceeded.');
assert(all(abs(uav.History.DesiredClimbRate) <= ap.maxVerticalSpeed + 0.5), ...
    'Vertical speed exceeded.');
assert(max(abs(diff(altitudes))) < 30, 'No sharp altitude jumps.');

disp('testFW2AltitudeLevels passed.');
