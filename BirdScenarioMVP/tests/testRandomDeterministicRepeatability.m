% testRandomDeterministicRepeatability - Same seed repeats scenario (random system).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 123;
config.sim.duration = 30;
config.sim.dt = 1;
config.analysis.showFigures = false;
config.export.enabled = false;

[scenarioA, ~] = runSimulation(config);
[scenarioB, ~] = runSimulation(config);

assert(scenarioA.Random.ScenarioSeed == 123, 'Scenario seed must match configured seed.');
assert(scenarioB.Random.ScenarioSeed == 123, 'Scenario seed must match configured seed.');

for i = 1:numel(scenarioA.Targets)
    a = scenarioA.Targets(i);
    b = scenarioB.Targets(i);

    assert(a.Metadata.RandomSeed == b.Metadata.RandomSeed, 'Target seeds must repeat.');
    assert(a.RCS == b.RCS, 'RCS must repeat.');
    assert(isequal(round(a.History.Position, 6), round(b.History.Position, 6)), ...
        'Position history must repeat.');
    assert(isequal(string(a.History.State), string(b.History.State)), ...
        'State history must repeat.');
end

disp('testRandomDeterministicRepeatability passed.');
