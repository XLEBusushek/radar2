% testExportCsv - Checks CSV export (ТЗ-06).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 10;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = true;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_csv');
config.export.saveMat = false;
config.export.saveCsv = true;
config.export.saveFigure = false;
config.export.csvFileName = 'test_bird_scenario_tracks.csv';

[~, output] = runSimulation(config);
outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);

csvPath = fullfile(outputFolder, config.export.csvFileName);
assert(isfile(csvPath), 'CSV export file must be created.');

T = readtable(csvPath);
assert(height(T) > 0, 'CSV table must not be empty.');

requiredColumns = {'Time', 'ID', 'Class', 'Subtype', 'X', 'Y', 'Z', ...
    'Vx', 'Vy', 'Vz', 'RCS', 'Visible', 'State', 'Mission'};
for i = 1:numel(requiredColumns)
    assert(ismember(requiredColumns{i}, T.Properties.VariableNames), ...
        'CSV must contain column: %s.', requiredColumns{i});
end

if isfile(csvPath)
    delete(csvPath);
end

disp('testExportCsv passed.');
