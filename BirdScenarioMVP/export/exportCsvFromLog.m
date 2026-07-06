function exportCsvFromLog(trajectoryLog, config, outputFolder)
% exportCsvFromLog - Export track CSV directly from TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
    outputFolder (1, :) char
end

rows = buildOutputTableRowsFromLog(trajectoryLog);
T = struct2table(rows);
csvPath = fullfile(outputFolder, config.export.csvFileName);
writetable(T, csvPath);
end
