% testMixedTargets - Проверяет птиц и квадрокоптеры вместе (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.fixedWing.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 20;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = true;
config.export.saveMat = false;
config.export.saveCsv = true;
config.export.saveFigure = false;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_mixed');
config.export.csvFileName = 'test_mixed_tracks.csv';

[scenario, output] = runSimulation(config);

birds = getScenarioBirds(scenario);
quadcopters = getScenarioQuadcopters(scenario);
assert(numel(birds) == config.birds.count, 'Bird count mismatch.');
assert(numel(quadcopters) == config.quadcopter.count, 'Quadcopter count mismatch.');
assert(numel(scenario.Targets) == config.birds.count + config.quadcopter.count, ...
    'Total target count mismatch.');

ids = [scenario.Targets.ID];
assert(numel(unique(ids)) == numel(ids), 'Target IDs must be unique.');
assert(min(ids) == 1 && max(ids) == numel(ids), 'IDs must be contiguous from 1.');

classes = string({output(end).Targets.Class});
assert(any(classes == "bird"), 'Output must contain birds.');
assert(any(classes == "air"), 'Output must contain quadcopters.');

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);

assert(any(strcmp(T.Class, 'bird')), 'CSV must contain birds.');
assert(any(strcmp(T.Class, 'air')), 'CSV must contain quadcopters.');
assert(ismember('WaypointIndex', T.Properties.VariableNames), 'CSV needs WaypointIndex.');

if isfile(csvPath)
    delete(csvPath);
end

disp('testMixedTargets passed.');
