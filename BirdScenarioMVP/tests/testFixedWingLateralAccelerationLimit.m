% testFixedWingLateralAccelerationLimit - Checks lateral acceleration cap (ТЗ-09F).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.sim.duration = 100;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

maxLat = config.fixedWing.antiBounce.maxLateralAcceleration;
tol = 0.5;
speed = vecnorm(uav.History.Velocity(:, 1:2), 2, 2);
turnRate = uav.History.TurnRateCommandDeg * pi / 180;
aLat = speed .* abs(turnRate);
valid = speed > config.fixedWing.minSpeed * 0.5 & isfinite(aLat);
assert(all(aLat(valid) <= maxLat + tol), 'Lateral acceleration exceeds configured limit.');

disp('testFixedWingLateralAccelerationLimit passed.');
