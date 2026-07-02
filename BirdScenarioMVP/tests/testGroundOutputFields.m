% testGroundOutputFields - Checks ground route fields in History/Output/CSV (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 1;
config.sim.duration = 10;
config.sim.dt = 1;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_ground_08c');
config.export.csvFileName = 'test_ground_08c.csv';
rng(config.sim.seed);

[scenario, output] = runSimulation(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);
historyFields = {'CurrentEdgeID', 'RouteProgress', 'RoadDeviation', ...
    'IsOffRoad', 'DriverProfile', 'GroundAction'};
outputFields = historyFields;
for i = 1:numel(historyFields)
    assert(isfield(vehicle.History, historyFields{i}), 'Missing History field: %s.', historyFields{i});
    assert(isfield(output(end).GroundVehicles, outputFields{i}), 'Missing Output field: %s.', outputFields{i});
end

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);
for i = 1:numel(outputFields)
    assert(ismember(outputFields{i}, T.Properties.VariableNames), ...
        'Missing CSV column: %s.', outputFields{i});
end
if isfile(csvPath)
    delete(csvPath);
end

disp('testGroundOutputFields passed.');
