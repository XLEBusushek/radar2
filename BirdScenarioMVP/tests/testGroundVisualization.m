% testGroundVisualization - Проверяет smoke path визуализации наземного транспорта и дорог (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 2;
config.sim.duration = 5;
config.sim.dt = 1;
config.visualization.enabled = true;
config.visualization.showRoads = true;
config.analysis.showFigures = false;
config.export.enabled = false;
setScenarioRNG(config.sim.random.seed);

[scenario, ~] = runSimulation(config);

fig3d = plotScenario(scenario, config);
assert(~isempty(fig3d) && isgraphics(fig3d), 'plotScenario must return a figure handle.');
figXY = plotXYTrajectories(scenario, config);
assert(~isempty(figXY) && isgraphics(figXY), 'plotXYTrajectories must return a figure handle.');

close(fig3d);
close(figXY);

disp('testGroundVisualization passed.');
