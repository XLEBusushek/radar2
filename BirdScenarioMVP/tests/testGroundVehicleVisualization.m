% testGroundVehicleVisualization - Checks road/route/vehicle plotting (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
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
rng(config.sim.seed);

[scenario, ~] = runSimulation(config);
fig3d = plotScenario(scenario, config);
assert(~isempty(fig3d) && isgraphics(fig3d), 'plotScenario must return a figure.');
figXY = plotXYTrajectories(scenario, config);
assert(~isempty(figXY) && isgraphics(figXY), 'plotXYTrajectories must return a figure.');
close(fig3d);
close(figXY);

disp('testGroundVehicleVisualization passed.');
