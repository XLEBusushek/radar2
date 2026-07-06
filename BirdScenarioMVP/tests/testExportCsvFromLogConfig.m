% testExportCsvFromLogConfig - csvFromLog=false must require legacy rebuild.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.sim.duration = 10;
config.sim.dt = 1;
config.export.enabled = false;
config.analysis.enabled = false;
config.log.buildLegacyOutput = false;
config.export.csvFromLog = false;

[~, trajectoryLog, ~] = runSimulation(config);

assert(~shouldExportCsvFromLog(config, struct([])), ...
    'csvFromLog=false must disable direct log CSV export.');
assert(needsLegacyOutputForExport(config, struct([])), ...
    'csvFromLog=false must require legacy output for CSV export.');

legacy = trajectoryLogToLegacyOutput(trajectoryLog, config);
outputFolder = fullfile(projectRoot, 'output', 'test_csv_from_log_config');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

exportConfig = config;
exportConfig.export.enabled = true;
exportConfig.export.outputFolder = outputFolder;
exportConfig.export.saveMat = false;
exportConfig.export.saveFigure = false;
exportConfig.export.csvFileName = 'legacy_path.csv';

exportCSV(legacy, exportConfig, outputFolder);
assert(isfile(fullfile(outputFolder, exportConfig.export.csvFileName)), ...
    'Legacy CSV export must succeed when csvFromLog=false.');

disp('testExportCsvFromLogConfig passed.');
