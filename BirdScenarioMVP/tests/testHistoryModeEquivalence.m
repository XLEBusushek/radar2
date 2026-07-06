% testHistoryModeEquivalence - full vs minimal history must not change simulation.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

baseConfig = defaultConfig();
baseConfig.sim.random.mode = "deterministic";
baseConfig.sim.random.seed = 42;
baseConfig.behavior.enabled = false;
baseConfig.birds.realism.enabled = false;
baseConfig.sim.duration = 30;
baseConfig.sim.dt = 1;
baseConfig.export.enabled = false;
baseConfig.analysis.enabled = false;

configFull = baseConfig;
configFull.log.historyMode = "full";

configMinimal = baseConfig;
configMinimal.log.historyMode = "minimal";

[scenarioFull, logFull, legacyFull] = runSimulation(configFull);
[scenarioMinimal, logMinimal, legacyMinimal] = runSimulation(configMinimal);

assert(numel(scenarioFull.Targets) == numel(scenarioMinimal.Targets), 'Target count mismatch.');
for i = 1:numel(scenarioFull.Targets)
    a = scenarioFull.Targets(i);
    b = scenarioMinimal.Targets(i);
    assert(isequal(round(a.Position, 6), round(b.Position, 6)), ...
        'Position mismatch for target %d.', a.ID);
    assert(isequal(round(a.Velocity, 6), round(b.Velocity, 6)), ...
        'Velocity mismatch for target %d.', a.ID);
    assert(a.State == b.State, 'State mismatch for target %d.', a.ID);
    assert(isequal(round(a.History.Position, 6), round(b.History.Position, 6)), ...
        'History position mismatch for target %d.', a.ID);
    assert(isequal(string(a.History.State), string(b.History.State)), ...
        'History state mismatch for target %d.', a.ID);

    fullFields = numel(fieldnames(a.History));
    minimalFields = numel(fieldnames(b.History));
    assert(minimalFields < fullFields, ...
        'Minimal history should have fewer fields for target %d.', a.ID);
end

assert(isequaln(legacyFull, legacyMinimal), 'Legacy output must match across history modes.');

outputFolder = fullfile(projectRoot, 'output', 'test_history_mode');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end
exportConfig = baseConfig;
exportConfig.export.enabled = true;
exportConfig.export.outputFolder = outputFolder;
exportConfig.export.saveMat = false;
exportConfig.export.saveFigure = false;
exportConfig.export.csvFileName = 'history_mode_full.csv';
exportOutputToCsv(legacyFull, exportConfig, outputFolder);
tableFull = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));
exportConfig.export.csvFileName = 'history_mode_minimal.csv';
exportOutputToCsv(legacyMinimal, exportConfig, outputFolder);
tableMinimal = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));
assert(isequal(tableFull.Properties.VariableNames, tableMinimal.Properties.VariableNames), ...
    'CSV columns must match.');
assert(height(tableFull) == height(tableMinimal), 'CSV row count must match.');

disp('testHistoryModeEquivalence passed.');
