% testGroundOutput - Checks ground output and CSV road fields (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 2;
config.sim.duration = 10;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_ground');
config.export.csvFileName = 'test_ground_tracks.csv';
setScenarioRNG(config.sim.random.seed);

[~, output] = runSimulation(config);
requiredFields = {'RoadID', 'Waypoint', 'SpeedLimit', 'RoadDeviation', ...
    'DesiredSpeed', 'Decision', 'BehaviorAction', 'BehaviorGoal'};

for k = 1:numel(output)
    step = output(k);
    assert(isfield(step, 'GroundVehicles'), 'Output step must have GroundVehicles.');
    for i = 1:numel(step.GroundVehicles)
        target = step.GroundVehicles(i);
        for f = 1:numel(requiredFields)
            assert(isfield(target, requiredFields{f}), 'Missing output field: %s.', requiredFields{f});
        end
        assert(isfinite(target.RoadDeviation), 'RoadDeviation must be finite.');
    end
end

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);
csvFields = {'RoadID', 'Waypoint', 'SpeedLimit', 'RoadDeviation'};
for f = 1:numel(csvFields)
    assert(ismember(csvFields{f}, T.Properties.VariableNames), ...
        'CSV missing column: %s.', csvFields{f});
end
assert(any(strcmp(T.Class, 'ground')), 'CSV must contain ground targets.');

if isfile(csvPath)
    delete(csvPath);
end

disp('testGroundOutput passed.');
