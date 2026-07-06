function exportMAT(trajectoryLog, legacyOutput, config, outputFolder)
% exportMAT - Save TrajectoryLog and legacy output to MAT.
arguments
    trajectoryLog (1, 1) struct
    legacyOutput struct
    config (1, 1) struct
    outputFolder (1, :) char
end

matPath = fullfile(outputFolder, config.export.matFileName);
output = legacyOutput;
save(matPath, 'trajectoryLog', 'output', 'config');
end
