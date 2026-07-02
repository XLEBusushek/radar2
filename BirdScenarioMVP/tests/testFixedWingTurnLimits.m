% testFixedWingTurnLimits - Checks heading turn-rate limit (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 30;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
headings = uav(1).History.CurrentHeading;
delta = abs(arrayfun(@wrapToPiLocal, diff(headings)));
limit = deg2rad(config.fixedWing.maxTurnRateDeg) * config.sim.dt + 1e-6;

assert(all(delta <= limit + 0.05), 'Heading change exceeds maxTurnRateDeg * dt.');

disp('testFixedWingTurnLimits passed.');

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
