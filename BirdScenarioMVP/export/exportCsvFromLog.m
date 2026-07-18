function exportCsvFromLog(trajectoryLog, config, outputFolder)
% exportCsvFromLog - Экспорт CSV трека напрямую из TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
    outputFolder (1, :) char
end

if hasIncrementalCsvRows(trajectoryLog)
    rows = trajectoryLog.CsvRows(1:trajectoryLog.CsvRowCount);
else
    rows = buildOutputTableRowsFromLog(trajectoryLog);
end
T = struct2table(rows);
csvPath = fullfile(outputFolder, config.export.csvFileName);
writetable(T, csvPath);
end
