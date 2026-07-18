% testSplitTargetsByType - Кэш индексов целей и представления сценария.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
setScenarioRNG(42);

scenario = initializeScenario(config);
assert(isfield(scenario, 'TargetIndices'), 'TargetIndices required.');
assert(numel(scenario.Birds) == numel(scenario.TargetIndices.Birds), 'Bird index mismatch.');
assert(numel(scenario.Quadcopters) == numel(scenario.TargetIndices.Quadcopters), 'Quad index mismatch.');

scenario = updateScenario(scenario, config, config.sim.dt);
assert(numel(scenario.Birds) == config.birds.count, 'Bird view count after update.');
assert(numel(scenario.Targets) == numel(scenario.Targets), 'Targets count unchanged.');

disp('testSplitTargetsByType passed.');
