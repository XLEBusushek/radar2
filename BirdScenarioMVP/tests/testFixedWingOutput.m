% testFixedWingOutput - Checks fixed-wing output and CSV fields (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 10;
config.export.csvFileName = 'test_fixed_wing_tracks.csv';
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_fixed_wing');

[~, output] = runSimulation(config);

requiredFields = {'CurrentHeading', 'TargetHeading', 'DesiredAltitude', ...
    'DesiredSpeed', 'DistanceToWaypoint', 'MissionComplete', 'LastNavigationEvent'};

for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        t = output(k).Targets(i);
        if t.Subtype ~= "fixedWingUAV"
            continue;
        end
        for f = 1:numel(requiredFields)
            assert(isfield(t, requiredFields{f}), 'Missing output field: %s.', requiredFields{f});
        end
    end
end

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);
for f = 1:numel(requiredFields)
    assert(ismember(requiredFields{f}, T.Properties.VariableNames), ...
        'Missing CSV column: %s.', requiredFields{f});
end
assert(any(strcmp(T.Subtype, 'fixedWingUAV')), 'CSV must contain fixed-wing UAV rows.');

if isfile(csvPath)
    delete(csvPath);
end

disp('testFixedWingOutput passed.');
