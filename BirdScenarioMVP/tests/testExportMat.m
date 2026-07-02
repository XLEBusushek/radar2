% testExportMat - Checks MAT export (ТЗ-06).
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
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_mat');
config.export.saveMat = true;
config.export.saveCsv = false;
config.export.saveFigure = false;
config.export.matFileName = 'test_bird_scenario_output.mat';

[scenario, output] = runSimulation(config);
outputFolder = ensureOutputFolder(config);
exportOutputToMat(scenario, output, config, outputFolder);

matPath = fullfile(outputFolder, config.export.matFileName);
assert(isfile(matPath), 'MAT export file must be created.');

loaded = load(matPath);
assert(isfield(loaded, 'scenario'), 'MAT file must contain scenario.');
assert(isfield(loaded, 'output'), 'MAT file must contain output.');
assert(isfield(loaded, 'config'), 'MAT file must contain config.');

if isfile(matPath)
    delete(matPath);
end

disp('testExportMat passed.');
