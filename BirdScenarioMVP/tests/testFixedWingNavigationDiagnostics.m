% testFixedWingNavigationDiagnostics - Checks navigation debug fields, CSV, plot, anomaly (ТЗ-09E).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 15;
config.visualization.enabled = false;
config.analysis.enabled = false;
config.export.enabled = true;
config.export.saveMat = false;
config.export.saveFigure = false;
config.export.fixedWingDebugCsv = true;
config.export.fixedWingDebugCsvFileName = 'test_fixed_wing_debug.csv';
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_fixed_wing_nav_debug');

[scenario, output] = runSimulation(config);

historyFields = {'CurrentWaypointIndex', 'CurrentWaypoint', 'NextWaypoint', ...
    'NavigationTarget', 'LookaheadPoint', 'CurrentHeading', 'TargetHeading', ...
    'HeadingErrorDeg', 'TurnRateCommandDeg', 'DistanceToWaypoint', ...
    'WaypointReached', 'Action', 'LastDecisionReason', 'BoundaryRecoveryActive', ...
    'FinalPhaseStarted', 'LoiterActive', 'HeadingJumpDeg', 'TargetPointJump', ...
    'AntiBounceActive', 'LastAntiBounceEvent', 'TimeOnCurrentLeg', ...
    'SmoothedLookaheadPoint', 'RawLookaheadPoint'};

outputFields = historyFields;

uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);
for f = 1:numel(historyFields)
    assert(isfield(uav.History, historyFields{f}), 'Missing history field: %s.', historyFields{f});
end

for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        t = output(k).Targets(i);
        if t.Subtype ~= "fixedWingUAV"
            continue;
        end
        for f = 1:numel(outputFields)
            assert(isfield(t, outputFields{f}), 'Missing output field: %s.', outputFields{f});
        end
    end
end

outputFolder = ensureOutputFolder(config);
exportFixedWingDebugCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.fixedWingDebugCsvFileName);
assert(isfile(csvPath), 'Debug CSV must be created.');
T = readtable(csvPath);
csvColumns = {'Time', 'ID', 'State', 'Action', 'CurrentWaypointIndex', ...
    'X', 'Y', 'Z', 'Vx', 'Vy', 'Vz', 'CurrentHeading', 'TargetHeading', ...
    'HeadingErrorDeg', 'TurnRateCommandDeg', 'DistanceToWaypoint', ...
    'WaypointReached', 'BoundaryRecoveryActive', 'FinalPhaseStarted', ...
    'LoiterActive', 'LastDecisionReason'};
for f = 1:numel(csvColumns)
    assert(ismember(csvColumns{f}, T.Properties.VariableNames), ...
        'Missing CSV column: %s.', csvColumns{f});
end
assert(height(T) > 0, 'Debug CSV must contain fixed-wing rows.');

config.analysis.enabled = true;
config.analysis.showFigures = false;
fig = plotFixedWingNavigationDebug(scenario, config);
assert(~isempty(fig) && isgraphics(fig), 'plotFixedWingNavigationDebug must return a figure.');
close(fig);

report = detectFixedWingNavigationAnomaly(uav, config);
assert(isstruct(report), 'Anomaly report must be a struct.');
assert(isfield(report, 'Anomalies'), 'Anomaly report must have Anomalies.');
assert(isfield(report, 'Summary'), 'Anomaly report must have Summary.');

if isfile(csvPath)
    delete(csvPath);
end

disp('testFixedWingNavigationDiagnostics passed.');
