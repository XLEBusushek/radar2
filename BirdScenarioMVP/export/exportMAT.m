function exportMAT(trajectoryLog, legacyOutput, config, outputFolder)
% exportMAT - Сохранить TrajectoryLog и legacy output в MAT.
arguments
    trajectoryLog (1, 1) struct
    legacyOutput struct
    config (1, 1) struct
    outputFolder (1, :) char
end

matPath = fullfile(outputFolder, config.export.matFileName);
output = legacyOutput;

useCompact = isfield(config, 'export') && isfield(config.export, 'matCompact') && ...
    config.export.matCompact;
if useCompact
    logForSave = trimTrajectoryLogForMat(trajectoryLog);
else
    logForSave = trajectoryLog;
    if isfield(logForSave, 'TargetHistoryCache')
        logForSave = rmfield(logForSave, 'TargetHistoryCache');
    end
end

trajectoryLog = logForSave;
fprintf('[BirdScenarioMVP] Writing MAT file...\n');
save(matPath, 'trajectoryLog', 'output', 'config', '-v7');
end
