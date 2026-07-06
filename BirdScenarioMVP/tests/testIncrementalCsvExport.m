% testIncrementalCsvExport - incremental CSV rows must match post-hoc export.
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
baseConfig.log.buildLegacyOutput = false;

configIncremental = baseConfig;
configIncremental.log.incrementalCsv = true;

configDeferred = baseConfig;
configDeferred.log.incrementalCsv = false;

[~, logIncremental, ~] = runSimulation(configIncremental);
[~, logDeferred, ~] = runSimulation(configDeferred);

assert(hasIncrementalCsvRows(logIncremental), 'Incremental log must store CSV rows.');
assert(~hasIncrementalCsvRows(logDeferred), 'Deferred log must not store CSV rows.');

outputFolder = fullfile(projectRoot, 'output', 'test_incremental_csv');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

exportConfig = baseConfig;
exportConfig.export.enabled = true;
exportConfig.export.outputFolder = outputFolder;
exportConfig.export.saveMat = false;
exportConfig.export.saveFigure = false;

exportConfig.export.csvFileName = 'incremental.csv';
exportCsvFromLog(logIncremental, exportConfig, outputFolder);
tableIncremental = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

exportConfig.export.csvFileName = 'deferred.csv';
exportCsvFromLog(logDeferred, exportConfig, outputFolder);
tableDeferred = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

assertCsvTablesEqual(sortrows(tableIncremental, {'Time', 'ID'}), ...
    sortrows(tableDeferred, {'Time', 'ID'}));

disp('testIncrementalCsvExport passed.');

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
