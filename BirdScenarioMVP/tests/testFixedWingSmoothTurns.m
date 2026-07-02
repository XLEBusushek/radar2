% testFixedWingSmoothTurns - Checks smoothed fixed-wing heading changes (ТЗ-09B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 80;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
headings = uav(1).History.CurrentHeading;
delta = abs(arrayfun(@wrapToPiLocal, diff(headings)));
limit = deg2rad(config.fixedWing.turn.maxTurnRateDeg) * config.sim.dt + 1e-6;

assert(all(delta <= limit + 0.05), 'Heading change exceeds smoothed turn limit.');
assert(all(delta < pi / 2), 'Heading jumps across wrap boundary.');
turnSeverity = uav(1).History.TurnSeverity;
assert(all(turnSeverity >= 0 & turnSeverity <= 1), 'TurnSeverity must be in [0, 1].');

disp('testFixedWingSmoothTurns passed.');

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
