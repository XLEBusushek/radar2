% testPerTargetSeeds - Проверяет стабильные и уникальные seed для каждой цели.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 77;
config.sim.random.usePerTargetSeeds = true;
config.analysis.showFigures = false;
config.export.enabled = false;

scenarioA = initializeScenario(config, initializeRandomSystem(config));
scenarioB = initializeScenario(config, initializeRandomSystem(config));

configOther = config;
configOther.sim.random.seed = 78;
scenarioC = initializeScenario(configOther, initializeRandomSystem(configOther));

seedsA = arrayfun(@(t) t.Metadata.RandomSeed, scenarioA.Targets);
seedsB = arrayfun(@(t) t.Metadata.RandomSeed, scenarioB.Targets);
seedsC = arrayfun(@(t) t.Metadata.RandomSeed, scenarioC.Targets);

assert(all(isfinite(seedsA)), 'Each target must have a RandomSeed.');
assert(numel(unique(seedsA)) == numel(seedsA), 'Target seeds must be unique.');
assert(isequal(seedsA, seedsB), 'Target seeds must repeat for same scenario seed.');
assert(~isequal(seedsA, seedsC), 'Target seeds must change for different scenario seed.');

disp('testPerTargetSeeds passed.');
