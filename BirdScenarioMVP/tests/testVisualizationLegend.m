% testVisualizationLegend - Проверяет уникальные элементы легенды XY (ТЗ-06C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 10;
config.sim.dt = 1;
config.analysis.showFigures = false;
config.analysis.saveFigures = false;

[scenario, ~] = runSimulation(config);

fig = plotXYTrajectories(scenario, config);
ax = gca;
legendObj = legend(ax);
assert(~isempty(legendObj), 'XY plot must have a legend.');

labels = string(legendObj.String);
allowed = ["Bird trajectories", "Quadcopter trajectories", "Start", "End", "Trees"];
assert(numel(labels) == numel(unique(labels)), ...
    'Legend entries must be unique.');
for i = 1:numel(labels)
    assert(any(labels(i) == allowed), ...
        'Unexpected legend entry: %s.', labels(i));
end

close(fig);
disp('testVisualizationLegend passed.');
