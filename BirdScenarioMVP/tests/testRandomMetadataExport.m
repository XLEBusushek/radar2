% testRandomMetadataExport - Проверяет случайные метаданные в output, CSV и MAT.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 456;
config.sim.duration = 10;
config.sim.dt = 1;
config.analysis.showFigures = false;
config.visualization.enabled = false;
config.export.enabled = true;
config.export.saveMat = true;
config.export.saveCsv = true;
config.export.saveFigure = false;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_random_metadata');
config.export.matFileName = 'test_random_metadata.mat';
config.export.csvFileName = 'test_random_metadata.csv';

[scenario, output] = runSimulation(config);

assert(isfield(scenario, 'Random'), 'scenario must contain Random state.');
assert(scenario.Random.ScenarioSeed == 456, 'scenario.Random must store seed.');
assert(scenario.Metadata.ScenarioSeed == 456, 'scenario.Metadata must store seed.');
assert(isfield(output, 'ScenarioSeed'), 'output must contain ScenarioSeed.');
assert(output(1).ScenarioSeed == 456, 'output ScenarioSeed must match.');
assert(isfield(output(1).Targets, 'RandomSeed'), 'target output must contain RandomSeed.');

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
exportOutputToMat(scenario, output, config, outputFolder);

csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);
requiredColumns = {'RandomMode', 'ScenarioSeed', 'TargetSeed'};
for i = 1:numel(requiredColumns)
    assert(ismember(requiredColumns{i}, T.Properties.VariableNames), ...
        'CSV missing random column: %s.', requiredColumns{i});
end
assert(all(T.ScenarioSeed == 456), 'CSV ScenarioSeed must match.');
assert(all(isfinite(T.TargetSeed)), 'CSV TargetSeed values must be finite.');

matPath = fullfile(outputFolder, config.export.matFileName);
S = load(matPath, 'scenario');
assert(isfield(S.scenario, 'Random'), 'MAT scenario must contain Random.');
assert(S.scenario.Random.ScenarioSeed == 456, 'MAT random seed must match.');

if isfile(csvPath)
    delete(csvPath);
end
if isfile(matPath)
    delete(matPath);
end

disp('testRandomMetadataExport passed.');
