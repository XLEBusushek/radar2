% testDirectCsvExport - CSV from TrajectoryLog must match legacy rebuild path.
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

[~, trajectoryLog, ~] = runSimulation(baseConfig);
legacyOutput = trajectoryLogToLegacyOutput(trajectoryLog, baseConfig);

outputFolder = fullfile(projectRoot, 'output', 'test_direct_csv');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

exportConfig = baseConfig;
exportConfig.export.enabled = true;
exportConfig.export.outputFolder = outputFolder;
exportConfig.export.saveMat = false;
exportConfig.export.saveFigure = false;

exportConfig.export.csvFileName = 'direct_from_log.csv';
exportCsvFromLog(trajectoryLog, exportConfig, outputFolder);
tableDirect = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

exportConfig.export.csvFileName = 'from_legacy.csv';
exportOutputToCsv(legacyOutput, exportConfig, outputFolder);
tableLegacy = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

assertCsvTablesEqual(sortrows(tableDirect, {'Time', 'ID'}), sortrows(tableLegacy, {'Time', 'ID'}));

disp('testDirectCsvExport passed.');

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
