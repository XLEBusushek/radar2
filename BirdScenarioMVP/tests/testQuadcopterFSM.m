% testQuadcopterFSM - Checks Idle -> Takeoff -> Transit transitions (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 1;
config.birds.count = 0;
config.sim.duration = 60;
config.sim.dt = 1;
config.quadcopter.fsm.idle.minTime = 0;
config.quadcopter.fsm.idle.maxTime = 2;
config.quadcopter.fsm.idle.takeoffProbability = 1.0;

[scenario, ~] = runSimulation(config);
qc = getScenarioQuadcopters(scenario);

states = string(qc.History.State);
assert(any(states == "Takeoff"), 'Must reach Takeoff state.');
assert(any(states == "Transit"), 'Must reach Transit state.');

takeoffIdx = find(states == "Takeoff", 1, 'first');
transitIdx = find(states == "Transit", 1, 'first');
assert(takeoffIdx < transitIdx, 'Takeoff must occur before Transit.');

disp('testQuadcopterFSM passed.');
