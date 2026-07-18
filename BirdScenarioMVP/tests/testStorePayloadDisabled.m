% testStorePayloadDisabled - storePayload=false должен исключать Payload из кадров лога.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

baseConfig = defaultConfig();
baseConfig.sim.random.mode = "deterministic";
baseConfig.sim.random.seed = 42;
baseConfig.behavior.enabled = false;
baseConfig.birds.realism.enabled = false;
baseConfig.sim.duration = 20;
baseConfig.sim.dt = 1;
baseConfig.export.enabled = false;
baseConfig.analysis.enabled = false;
baseConfig.log.buildLegacyOutput = false;

configWithPayload = baseConfig;
configWithPayload.log.storePayload = true;

configNoPayload = baseConfig;
configNoPayload.log.storePayload = false;

[scenarioWith, logWith, ~] = runSimulation(configWithPayload);
[scenarioNo, logNo, ~] = runSimulation(configNoPayload);

assert(hasLogPayload(logWith), 'storePayload=true must record Payload.');
assert(~hasLogPayload(logNo), 'storePayload=false must omit Payload.');

for i = 1:numel(scenarioWith.Targets)
    assert(isequal(round(scenarioWith.Targets(i).Position, 6), ...
        round(scenarioNo.Targets(i).Position, 6)), ...
        'Kinematics must match for target %d.', scenarioWith.Targets(i).ID);
end

outputFolder = fullfile(projectRoot, 'output', 'test_store_payload');
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

exportConfig = baseConfig;
exportConfig.export.enabled = true;
exportConfig.export.outputFolder = outputFolder;
exportConfig.export.saveMat = false;
exportConfig.export.saveFigure = false;

exportConfig.export.csvFileName = 'with_payload.csv';
exportCsvFromLog(logWith, exportConfig, outputFolder);
tableWith = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

exportConfig.export.csvFileName = 'no_payload.csv';
exportCsvFromLog(logNo, exportConfig, outputFolder);
tableNo = readtable(fullfile(outputFolder, exportConfig.export.csvFileName));

kinematicCols = {'Time', 'ID', 'X', 'Y', 'Z', 'Vx', 'Vy', 'Vz', 'State'};
for i = 1:numel(kinematicCols)
    col = kinematicCols{i};
    assert(isequaln(sortrows(tableWith(:, col)), sortrows(tableNo(:, col))), ...
        'Kinematic CSV column mismatch: %s.', col);
end

disp('testStorePayloadDisabled passed.');

function tf = hasLogPayload(trajectoryLog)
tf = false;
numFrames = getLogFrameCount(trajectoryLog);
for k = 1:numFrames
    frame = trajectoryLog.Frames(k);
    if isempty(frame.Targets)
        continue;
    end
    for i = 1:numel(frame.Targets)
        if isfield(frame.Targets(i), 'Payload')
            tf = true;
            return;
        end
    end
end
end
