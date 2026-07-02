% testQuadcopterScan - Checks scan state behavior (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 1;
config.birds.count = 0;
config.sim.random.seed = 43;
setScenarioRNG(config.sim.random.seed);
config.sim.duration = 60;
config.sim.dt = 1;
config.quadcopter.fsm.transit.hoverProbability = 0.0;
config.quadcopter.fsm.transit.scanProbability = 1.0;
config.quadcopter.fsm.transit.nextWaypointProbability = 0.0;
config.quadcopter.fsm.returnProbability = 0.0;

scenario = initializeScenario(config);
qcIdx = find(arrayfun(@(t) t.Class == "air", scenario.Targets), 1);
scenario.Targets(qcIdx).State = "Transit";
scenario.Targets(qcIdx).Position = [500; 500; 50];
scenario.Targets(qcIdx).Payload.CurrentWaypoint = [505; 505; 50];
scenario.Targets(qcIdx).Payload.Waypoints(1, :) = [505, 505, 50];
scenario.Targets(qcIdx).Payload.DistanceToWaypoint = 5;
scenario.Targets(qcIdx).Payload.DesiredSpeed = 8;

for k = 1:config.sim.duration
    scenario = updateScenario(scenario, config, config.sim.dt);
end

qc = scenario.Targets(qcIdx);
states = string(qc.History.State);
scanIdx = find(states == "Scan");
assert(~isempty(scanIdx), 'Scan state must occur.');

pos = qc.History.Position(scanIdx, :);
center = mean(pos, 1);
dist = vecnorm(pos - center, 2, 2);
maxRadius = config.quadcopter.scanRadiusRange(2) + 20;
assert(all(dist <= maxRadius), 'Scan motion must stay within radius.');

vel = qc.History.Velocity(scanIdx, :);
speeds = vecnorm(vel, 2, 2);
scanRange = config.quadcopter.scanSpeedRange;
assert(all(speeds <= scanRange(2) + 3), 'Scan speed must be in range.');

disp('testQuadcopterScan passed.');
