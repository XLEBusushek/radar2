% main.m - Entry point for BirdScenarioMVP project.
clear;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

config = defaultConfig();
config.export.outputFolder = fullfile(projectRoot, "output");
config.log.buildLegacyOutput = false;
config = applyRunProfile(config, "interactive");
config.fixedWing2.count = 3;
config.groundVehicle.count = 4;
config.visualization.showRoads = true;
config.analysis.showFigures = true;
% config.tests.runOnStartup = true;  % set true to run runAllTests before simulation

runStartupTests(config);

[scenario, trajectoryLog, ~] = runSimulation(config);

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
    config.export.deferScenarioFigureDisplay = true;
    config.export.analysisFiguresAlreadySaved = config.analysis.enabled && ...
        config.analysis.saveFigures;
    scenarioFig = exportFromLog(trajectoryLog, config, env);
    fprintf('Results saved to: %s\n', ensureOutputFolder(config));
    disp('BirdScenarioMVP finished successfully.');
    if ~isempty(scenarioFig) && isgraphics(scenarioFig)
        fprintf('[BirdScenarioMVP] Opening 3D window (render may take a moment)...\n');
        set(scenarioFig, 'Visible', 'on');
    end
end
