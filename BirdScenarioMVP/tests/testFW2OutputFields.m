% testFW2OutputFields - History, Output, CSV fields (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 1;
config.fixedWing.count = 0;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 15;
config.export.csvFileName = 'test_fw2_output.csv';
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_fw2_output');
setScenarioRNG(42);

[scenario, output] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

historyFields = {'RouteIndex', 'CurrentLegProgress', 'CurrentHeading', 'TargetHeading', ...
    'HeadingErrorDeg', 'TurnRateCommandDeg', 'CurrentSpeed', 'TargetSpeed', ...
    'FlightLevel', 'TargetFlightLevel', 'DesiredClimbRate', 'ClimbAngleDeg', ...
    'DistanceToBoundary', 'InWarningZone', 'InCriticalZone', 'BorderFollowing', 'LastFW2Event'};
for f = 1:numel(historyFields)
    assert(isfield(uav.History, historyFields{f}), 'Missing history: %s.', historyFields{f});
end

outputFields = {'RouteIndex', 'CurrentLegProgress', 'CurrentSpeed', 'TargetSpeed', ...
    'LastFW2Event', 'DistanceToBoundary', 'InWarningZone'};
for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        if output(k).Targets(i).Subtype ~= "fixedWingUAV"
            continue;
        end
        for f = 1:numel(outputFields)
            assert(isfield(output(k).Targets(i), outputFields{f}), 'Missing output: %s.', outputFields{f});
        end
    end
end

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);
csvFields = {'RouteIndex', 'CurrentLegProgress', 'CurrentHeading', 'TargetHeading', ...
    'HeadingErrorDeg', 'TurnRateCommandDeg', 'CurrentSpeed', 'TargetSpeed', ...
    'FlightLevel', 'TargetFlightLevel', 'DesiredClimbRate', 'ClimbAngleDeg', ...
    'DistanceToBoundary', 'InWarningZone', 'InCriticalZone', 'BorderFollowing', 'LastFW2Event'};
for f = 1:numel(csvFields)
    assert(ismember(csvFields{f}, T.Properties.VariableNames), 'Missing CSV: %s.', csvFields{f});
end
if isfile(csvPath)
    delete(csvPath);
end

disp('testFW2OutputFields passed.');
