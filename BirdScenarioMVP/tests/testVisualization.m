% testVisualization - Проверяет 3D-отрисовку сценария (ТЗ-06).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 15;
config.sim.dt = 1;
config.visualization.enabled = true;
config.export.enabled = false;

[scenario, ~] = runSimulation(config);

fig = plotScenario(scenario, config);
assert(~isempty(fig) && isgraphics(fig), 'plotScenario must return a figure handle.');

close(fig);

disp('testVisualization passed.');
