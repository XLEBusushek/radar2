% testFixedWingNoSharpClimb - Checks no abrupt climb/descent commands (ТЗ-09B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 120;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

climbRate = uav.History.DesiredClimbRate;
climbAngle = uav.History.ClimbAngleDeg;
z = uav.History.Position(:, 3);
twoStepDz = abs(z(3:end) - z(1:end-2));

assert(all(abs(climbRate) <= config.fixedWing.maxVerticalSpeed + 1e-6), ...
    'DesiredClimbRate exceeds maxVerticalSpeed.');
assert(all(climbAngle <= config.fixedWing.flightLevel.maxClimbAngleDeg + 0.5), ...
    'ClimbAngleDeg too high.');
assert(all(climbAngle >= -config.fixedWing.flightLevel.maxDescentAngleDeg - 0.5), ...
    'ClimbAngleDeg too low.');
assert(isempty(twoStepDz) || max(twoStepDz) < 25, ...
    'Altitude changes too sharply over 1-2 steps.');

disp('testFixedWingNoSharpClimb passed.');
