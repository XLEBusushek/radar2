% testRandomMetadata - Случайные метаданные присутствуют в scenario, output, CSV и MAT.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.sim.duration = 5;
config.sim.dt = 1;
config.analysis.showFigures = false;
config.visualization.enabled = false;
config.export.enabled = true;
config.export.saveMat = true;
config.export.saveCsv = true;
config.export.saveFigure = false;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_random_metadata_r01');
config.export.matFileName = 'test_random_metadata_r01.mat';
config.export.csvFileName = 'test_random_metadata_r01.csv';

[scenario, output] = runSimulation(config);

assert(isfield(scenario, 'Random'), 'scenario.Random is required.');
assert(isfield(scenario.Random, 'ScenarioSeed'), 'scenario.Random.ScenarioSeed is required.');
assert(scenario.Metadata.ScenarioSeed == 42, 'scenario.Metadata.ScenarioSeed must match.');

for i = 1:numel(scenario.Targets)
    assert(isfield(scenario.Targets(i).Metadata, 'RandomSeed'), ...
        'Each target must have Metadata.RandomSeed.');
    assert(isfield(scenario.Targets(i).Metadata, 'RandomMode'), ...
        'Each target must have Metadata.RandomMode.');
end

assert(isfield(output, 'ScenarioSeed'), 'Output must contain ScenarioSeed.');
assert(isfield(output(1).Targets, 'TargetSeed'), 'Target output must contain TargetSeed.');

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

matPath = fullfile(outputFolder, config.export.matFileName);
S = load(matPath, 'scenario');
assert(isfield(S.scenario, 'Random'), 'MAT scenario must contain Random.');
assert(S.scenario.Metadata.ScenarioSeed == 42, 'MAT scenario seed must match.');

if isfile(csvPath)
    delete(csvPath);
end
if isfile(matPath)
    delete(matPath);
end

disp('testRandomMetadata passed.');
