% testFW2AltitudeSmoothness - Лимиты вертикального движения (ТЗ-09S).
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
ap = config.fixedWing2.altitudeProfile;

assert(all(abs(uav.History.DesiredClimbRate) <= ap.maxVerticalSpeed + 0.2), ...
    'Vertical speed exceeded.');
assert(all(abs(uav.History.ClimbAngleDeg) <= ap.maxClimbAngleDeg + 1), ...
    'Climb angle exceeded.');
assert(all(uav.History.ClimbAngleDeg >= -ap.maxDescentAngleDeg - 1), ...
    'Descent angle exceeded.');

altitudes = uav.History.Position(:, 3);
maxJump = ap.maxVerticalSpeed * config.sim.dt + 0.5;
for k = 2:numel(altitudes)
    assert(abs(altitudes(k) - altitudes(k - 1)) <= maxJump, 'Sharp altitude jump.');
end

disp('testFW2AltitudeSmoothness passed.');
