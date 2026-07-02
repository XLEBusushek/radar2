% testFixedWingSmoothAltitude - Checks smooth flight-level altitude changes (ТЗ-09B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 100;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

z = uav.History.Position(:, 3);
vz = diff(z) / config.sim.dt;
climbAngles = uav.History.ClimbAngleDeg;
assert(all(abs(vz) <= config.fixedWing.maxVerticalSpeed + 0.5), ...
    'Vertical speed exceeds maxVerticalSpeed.');
assert(all(climbAngles <= config.fixedWing.flightLevel.maxClimbAngleDeg + 0.5), ...
    'Climb angle exceeds maxClimbAngleDeg.');
assert(all(climbAngles >= -config.fixedWing.flightLevel.maxDescentAngleDeg - 0.5), ...
    'Descent angle exceeds maxDescentAngleDeg.');
assert(max(abs(diff(z))) < 15, 'Altitude jumps too sharply between steps.');

disp('testFixedWingSmoothAltitude passed.');
