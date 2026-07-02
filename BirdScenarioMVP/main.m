% main.m - Entry point for BirdScenarioMVP project.
clear;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing.count = 3;
config.groundVehicle.count = 4;
config.visualization.showRoads = true;

[scenario, output] = runSimulation(config);

fprintf('Targets: birds=%d, quadcopters=%d, fixedWingUAVs=%d, groundVehicles=%d\n', ...
    numel(getScenarioBirds(scenario)), numel(getScenarioQuadcopters(scenario)), ...
    numel(getScenarioFixedWingUAVs(scenario)), numel(getScenarioGroundVehicles(scenario)));

show3D = config.visualization.enabled;
if isfield(config, 'analysis') && isfield(config.analysis, 'show3D')
    show3D = show3D && config.analysis.show3D;
end

if show3D
    plotScenario(scenario, config);
end

if config.analysis.enabled
    plotAnalysisFigures(scenario, config);
end

if config.export.enabled
    exportScenarioResults(scenario, output, config);
end

disp('BirdScenarioMVP finished successfully.');
