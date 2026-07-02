% testQuadcopterTakeoff - Checks vertical takeoff behavior (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 1;
config.birds.count = 0;
config.sim.duration = 40;
config.sim.dt = 1;
config.quadcopter.fsm.idle.minTime = 0;
config.quadcopter.fsm.idle.maxTime = 1;
config.quadcopter.fsm.idle.takeoffProbability = 1.0;

[scenario, ~] = runSimulation(config);
qc = getScenarioQuadcopters(scenario);

altitudes = qc.History.Position(:, 3);
assert(max(altitudes) > 10, 'Altitude must increase during takeoff.');
assert(any(string(qc.History.State) == "Transit"), 'Must transition to Transit.');

maxSpeed = config.quadcopter.speedRange(2);
vel = qc.History.Velocity;
speeds = vecnorm(vel, 2, 2);
assert(all(speeds <= maxSpeed + 1e-3), 'Speed must stay within limits.');

disp('testQuadcopterTakeoff passed.');
