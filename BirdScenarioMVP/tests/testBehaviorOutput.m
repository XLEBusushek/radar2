% testBehaviorOutput - Checks Behavior fields in Output and CSV (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.behavior.decisionPeriodRange = [0.5, 0.5];
config.birds.realism.enabled = false;
config.sim.duration = 20;
config.sim.dt = 1;
config.export.enabled = true;
config.export.saveMat = false;
config.export.saveCsv = true;
config.export.saveFigure = false;
config.export.outputFolder = fullfile(projectRoot, 'output', 'test_behavior_output');
config.export.csvFileName = 'test_behavior_tracks.csv';

[~, output] = runSimulation(config);

requiredFields = {'BehaviorAction', 'BehaviorReason', 'BehaviorGoal', 'BehaviorProfile'};
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

disp('testBehaviorOutput passed.');
