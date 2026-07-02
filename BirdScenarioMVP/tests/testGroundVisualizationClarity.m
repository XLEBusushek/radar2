% testGroundVisualizationClarity - Checks clear roads/vehicles visualization (ТЗ-08B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 2;
config.visualization.showRoads = true;
config.analysis.showFigures = false;
config.export.enabled = false;
config.sim.duration = 8;
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

[scenario, ~] = runSimulation(config);

lastwarn('');
fig = plotScenario(scenario, config);
[warnMsg, ~] = lastwarn();
assert(isempty(warnMsg), 'plotScenario must not emit legend warnings.');
assert(~isempty(fig) && isgraphics(fig), 'plotScenario must return a valid figure.');

ax = gca;
legendObj = legend(ax);
labels = string(legendObj.String);
assert(numel(labels) == numel(unique(labels)), 'Legend entries must be unique.');
assert(any(labels == "Road network"), 'Legend must include road network.');
assert(any(labels == "Ground vehicle trajectories"), 'Legend must include ground vehicles.');

close(fig);
disp('testGroundVisualizationClarity passed.');
