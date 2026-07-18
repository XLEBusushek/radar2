% demoRandomScenario - Запускать новый случайный сценарий при каждом вызове.
clear;
clc;

projectRoot = fileparts(mfilename('fullpath'));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "randomized";

[scenario, output] = runSimulation(config);

plotScenario(scenario, config);
plotAnalysisFigures(scenario, config);
exportScenarioResults(scenario, output, config);

fprintf('Randomized scenario seed: %d\n', scenario.Random.ScenarioSeed);
