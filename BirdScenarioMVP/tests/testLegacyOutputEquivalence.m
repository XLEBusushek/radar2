% testLegacyOutputEquivalence - legacyPerFrame on/off должны давать идентичный CSV.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

baseConfig = defaultConfig();
baseConfig.sim.random.mode = "deterministic";
baseConfig.sim.random.seed = 42;
baseConfig.behavior.enabled = false;
baseConfig.birds.realism.enabled = false;
baseConfig.sim.duration = 30;
baseConfig.sim.dt = 1;
baseConfig.visualization.enabled = false;
baseConfig.analysis.enabled = false;
baseConfig.export.enabled = false;
setScenarioRNG(42);

configOn = baseConfig;
configOn.log.legacyPerFrame = true;
[~, logOn, legacyOn] = runSimulation(configOn);

configOff = baseConfig;
configOff.log.legacyPerFrame = false;
[~, logOff, legacyOff] = runSimulation(configOff);
legacyOffRebuilt = trajectoryLogToLegacyOutput(logOff, configOff);

assert(numel(legacyOn) == numel(legacyOff), 'Legacy frame count mismatch.');
assert(isequaln(legacyOff, legacyOffRebuilt), 'Rebuild must match runSimulation legacy output.');

outputFolder = fullfile(projectRoot, 'output', 'test_legacy_equiv');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

exportConfig = baseConfig;
exportConfig.export.enabled = true;
exportConfig.export.outputFolder = outputFolder;
exportConfig.export.saveMat = false;
exportConfig.export.saveFigure = false;

exportConfig.export.csvFileName = 'legacy_on.csv';
exportOutputToCsv(legacyOn, exportConfig, outputFolder);
tableOn = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

exportConfig.export.csvFileName = 'legacy_off.csv';
exportOutputToCsv(legacyOff, exportConfig, outputFolder);
tableOff = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

assertCsvTablesEqual(sortrows(tableOn, {'Time', 'ID'}), sortrows(tableOff, {'Time', 'ID'}));

assert(~hasStoredLegacyExport(logOff), 'Optimized log must not store LegacyExport.');
assert(hasStoredLegacyExport(logOn), 'legacyPerFrame=true must store LegacyExport.');

disp('testLegacyOutputEquivalence passed.');

function assertCsvTablesEqual(t1, t2)
assert(isequal(t1.Properties.VariableNames, t2.Properties.VariableNames), ...
    'CSV column names must match.');
assert(height(t1) == height(t2), 'CSV row count must match.');
for i = 1:numel(t1.Properties.VariableNames)
    col = t1.Properties.VariableNames{i};
    v1 = t1.(col);
    v2 = t2.(col);
    if isnumeric(v1) || islogical(v1)
        assert(isequaln(v1, v2), 'CSV column mismatch: %s.', col);
    else
        assert(isequal(string(v1), string(v2)), 'CSV column mismatch: %s.', col);
    end
end
end

function tf = hasStoredLegacyExport(trajectoryLog)
tf = isfield(trajectoryLog.Frames(1), 'LegacyExport');
end
