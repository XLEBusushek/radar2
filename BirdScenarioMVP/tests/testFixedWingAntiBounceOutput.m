% testFixedWingAntiBounceOutput - Checks anti-bounce fields in history/output/CSV (ТЗ-09F).
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
config.sim.duration = 20;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = true;
config.export.saveMat = false;
config.export.saveFigure = false;

[scenario, output] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

historyFields = {'RawNavigationTarget', 'SmoothedNavigationTarget', ...
    'RawLookaheadPoint', 'SmoothedLookaheadPoint', 'RawTargetHeading', ...
    'SmoothedTargetHeading', 'HeadingJumpDeg', 'TargetPointJump', ...
    'AntiBounceActive', 'LastAntiBounceEvent', 'TimeOnCurrentLeg'};
for f = 1:numel(historyFields)
    assert(isfield(uav.History, historyFields{f}), 'Missing history field: %s.', historyFields{f});
end

outputFields = {'HeadingJumpDeg', 'TargetPointJump', 'AntiBounceActive', ...
    'LastAntiBounceEvent', 'TimeOnCurrentLeg'};
found = false;
for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        if output(k).Targets(i).Subtype ~= "fixedWingUAV"
            continue;
        end
        found = true;
        t = output(k).Targets(i);
        for f = 1:numel(outputFields)
            assert(isfield(t, outputFields{f}), 'Missing output field: %s.', outputFields{f});
        end
    end
end
assert(found, 'Output must contain fixed-wing targets.');

csvPath = fullfile(ensureOutputFolder(config), config.export.csvFileName);
if isfile(csvPath)
    T = readtable(csvPath);
    csvCols = {'HeadingJumpDeg', 'TargetPointJump', 'AntiBounceActive', ...
        'LastAntiBounceEvent', 'TimeOnCurrentLeg'};
    for f = 1:numel(csvCols)
        assert(ismember(csvCols{f}, T.Properties.VariableNames), ...
            'Missing CSV column: %s.', csvCols{f});
    end
end

disp('testFixedWingAntiBounceOutput passed.');
