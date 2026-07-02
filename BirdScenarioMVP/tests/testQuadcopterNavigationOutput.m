% testQuadcopterNavigationOutput - Checks navigation fields in History/Output/CSV (ТЗ-07C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.birds.count = 1;
config.quadcopter.count = 2;
config.behavior.enabled = true;
config.behavior.decisionPeriodRange = [0.5, 0.5];
config.sim.duration = 30;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = true;
config.export.saveMat = false;
config.export.saveCsv = true;
config.export.saveFigure = false;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_quadcopter_navigation_output');
config.export.csvFileName = 'test_quadcopter_navigation_tracks.csv';
config.analysis.enabled = false;
config.debug.verbose = false;

[scenario, output] = runSimulation(config);

requiredFields = {'NoProgressTime', 'ForceDirectToWaypoint', ...
    'TotalXYExcursion', 'MaxAltitudeReached', 'MinAltitudeReached', ...
    'LastNavigationEvent'};

quadcopters = getScenarioQuadcopters(scenario);
for i = 1:numel(quadcopters)
    history = quadcopters(i).History;
    for f = 1:numel(requiredFields)
        assert(isfield(history, requiredFields{f}), ...
            'History missing field: %s.', requiredFields{f});
    end
end

for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        targetOut = output(k).Targets(i);
        for f = 1:numel(requiredFields)
            assert(isfield(targetOut, requiredFields{f}), ...
                'Output missing field: %s.', requiredFields{f});
        end
    end
end

outputFolder = ensureOutputFolder(config);
exportOutputToCsv(output, config, outputFolder);
csvPath = fullfile(outputFolder, config.export.csvFileName);
T = readtable(csvPath);

for f = 1:numel(requiredFields)
    assert(ismember(requiredFields{f}, T.Properties.VariableNames), ...
        'CSV missing column: %s.', requiredFields{f});
end

if isfile(csvPath)
    delete(csvPath);
end

disp('testQuadcopterNavigationOutput passed.');
