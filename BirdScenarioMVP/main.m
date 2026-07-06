% main.m - Entry point for BirdScenarioMVP project.
clear;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

config = defaultConfig();
config = applyRunProfile(config, "interactive");
config.fixedWing2.count = 3;
config.groundVehicle.count = 4;
config.visualization.showRoads = true;
config.analysis.showFigures = true;
% config.tests.runOnStartup = true;  % set true to run runAllTests before simulation

runStartupTests(config);

[scenario, trajectoryLog, output] = runSimulation(config);

fprintf('Targets: birds=%d, quadcopters=%d, fixedWingUAVs=%d, groundVehicles=%d\n', ...
    numel(getScenarioBirds(scenario)), numel(getScenarioQuadcopters(scenario)), ...
    numel(getScenarioFixedWingUAVs(scenario)), numel(getScenarioGroundVehicles(scenario)));

env = buildEnvironmentContext(scenario, config);
trajectoryLog = attachTargetHistoryCache(trajectoryLog);

if config.analysis.enabled
    runVisualization(trajectoryLog, env, config);
    runAnalysis(trajectoryLog, config);
end

if config.export.enabled
    exportFromLog(trajectoryLog, config, env, output);
end

disp('BirdScenarioMVP finished successfully.');
