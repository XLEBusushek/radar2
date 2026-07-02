% testFixedWingFlightRealismOutput - Checks flight realism History/Output/CSV fields (ТЗ-09B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 10;
config.export.csvFileName = 'test_fixed_wing_realism_tracks.csv';
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_fixed_wing_realism');

[scenario, output] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

requiredHistory = {'FlightLevel', 'TargetFlightLevel', 'AltitudeError', ...
    'DesiredClimbRate', 'ClimbAngleDeg', 'TurnSeverity', ...
    'NavigationLookaheadPoint', 'CornerCuttingActive'};
for i = 1:numel(requiredHistory)
    assert(isfield(uav.History, requiredHistory{i}), ...
        'Missing History field: %s.', requiredHistory{i});
end

requiredOutput = {'FlightLevel', 'TargetFlightLevel', 'AltitudeError', ...
    'DesiredClimbRate', 'ClimbAngleDeg', 'TurnSeverity', 'CornerCuttingActive'};
for k = 1:numel(output)
    t = output(k).FixedWingUAVs(1);
    for i = 1:numel(requiredOutput)
        assert(isfield(t, requiredOutput{i}), 'Missing Output field: %s.', requiredOutput{i});
    end
end

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);
for i = 1:numel(requiredOutput)
    assert(ismember(requiredOutput{i}, T.Properties.VariableNames), ...
        'Missing CSV column: %s.', requiredOutput{i});
end
assert(any(strcmp(T.Subtype, 'fixedWingUAV')), 'CSV must contain fixed-wing rows.');

if isfile(csvPath)
    delete(csvPath);
end

disp('testFixedWingFlightRealismOutput passed.');
