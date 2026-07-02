% testRandomizedMainDifferentRuns - Randomized mode produces different runs.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "randomized";
config.sim.duration = 5;
config.sim.dt = 1;
config.analysis.showFigures = false;
config.visualization.enabled = false;
config.export.enabled = false;

[scenarioA, ~] = runSimulation(config);
pause(0.02);
[scenarioB, ~] = runSimulation(config);

assert(scenarioA.Random.ScenarioSeed ~= scenarioB.Random.ScenarioSeed, ...
    'Randomized runs must use different scenario seeds.');

treePositionsA = reshape([scenarioA.Trees.Position], 3, []).';
treePositionsB = reshape([scenarioB.Trees.Position], 3, []).';
targetPositionsA = reshape([scenarioA.Targets.Position], 3, []).';
targetPositionsB = reshape([scenarioB.Targets.Position], 3, []).';

differentTrees = ~isequal(round(treePositionsA, 6), round(treePositionsB, 6));
differentTargets = ~isequal(round(targetPositionsA, 6), round(targetPositionsB, 6));
assert(differentTrees || differentTargets, ...
    'Randomized runs must differ in trees or target starts.');

disp('testRandomizedMainDifferentRuns passed.');
