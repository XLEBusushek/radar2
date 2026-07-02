% testDeterministicRepeatability - Same seed repeats scenario and output.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 123;
config.sim.duration = 20;
config.sim.dt = 1;
config.analysis.showFigures = false;
config.visualization.enabled = false;
config.export.enabled = false;

[scenarioA, outputA] = runSimulation(config);
[scenarioB, outputB] = runSimulation(config);

assert(scenarioA.Random.ScenarioSeed == 123, 'First scenario seed must match.');
assert(scenarioB.Random.ScenarioSeed == 123, 'Second scenario seed must match.');

for i = 1:numel(scenarioA.Targets)
    assert(scenarioA.Targets(i).Metadata.RandomSeed == ...
        scenarioB.Targets(i).Metadata.RandomSeed, 'Target seeds must repeat.');
    assert(isequal(round(scenarioA.Targets(i).History.Position, 6), ...
        round(scenarioB.Targets(i).History.Position, 6)), ...
        'Target position histories must repeat.');
end

for k = 1:numel(outputA)
    assert(outputA(k).ScenarioSeed == outputB(k).ScenarioSeed, ...
        'Output scenario seeds must repeat.');
    for i = 1:numel(outputA(k).Targets)
        assert(isequal(round(outputA(k).Targets(i).Position, 6), ...
            round(outputB(k).Targets(i).Position, 6)), ...
            'Output target positions must repeat.');
    end
end

disp('testDeterministicRepeatability passed.');
