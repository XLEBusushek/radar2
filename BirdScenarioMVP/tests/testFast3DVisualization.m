% testFast3DVisualization - Fast 3D mode must build and save scenario figure.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.sim.duration = 10;
config.sim.dt = 1;
config.analysis.enabled = false;
config.analysis.showFigures = false;
config.export.enabled = false;
config.visualization.showRoads = true;
config.visualization.fast3D = true;

[scenario, trajectoryLog, ~] = runSimulation(config);
env = buildEnvironmentContext(scenario, config);
trajectoryLog = attachTargetHistoryCache(trajectoryLog);

tStart = tic;
fig = plotScenarioFromLog(trajectoryLog, env, config);
buildTime = toc(tStart);
assert(isgraphics(fig, 'figure'), '3D figure must be created.');
assert(isFast3DVisualization(config), 'Test config must use fast3D.');
assert(~shouldPlotStateSegments(config), 'fast3D must disable state segments.');

outputFolder = fullfile(projectRoot, 'output', 'test_fast_3d');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
figPath = fullfile(outputFolder, 'fast_3d.png');
tStart = tic;
saveFigureFile(fig, figPath, config);
saveTime = toc(tStart);
close(fig);

assert(isfile(figPath), 'Fast 3D figure file must be written.');
fprintf('fast3D build=%.3fs save=%.3fs\n', buildTime, saveTime);

disp('testFast3DVisualization passed.');
