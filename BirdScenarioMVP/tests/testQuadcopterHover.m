% testQuadcopterHover - Проверяет поведение состояния Hover (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 1;
config.birds.count = 0;
config.sim.random.seed = 42;
setScenarioRNG(config.sim.random.seed);
config.sim.duration = 60;
config.sim.dt = 1;
config.quadcopter.fsm.transit.hoverProbability = 1.0;
config.quadcopter.fsm.transit.scanProbability = 0.0;
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
hoverIdx = find(states == "Hover");
assert(~isempty(hoverIdx), 'Hover state must occur.');

vel = qc.History.Velocity(hoverIdx, :);
speeds = vecnorm(vel, 2, 2);
assert(all(speeds < 5), 'Hover speed must be low.');

pos = qc.History.Position(hoverIdx, :);
anchor = qc.Payload.HoverAnchor(:).';
if isempty(anchor)
    anchor = pos(1, :);
end
deviation = vecnorm(pos - anchor, 2, 2);
assert(max(deviation) < 20, 'Hover position drift must be small.');

disp('testQuadcopterHover passed.');
