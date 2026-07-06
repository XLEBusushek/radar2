function tf = hasIncrementalCsvRows(trajectoryLog)
% hasIncrementalCsvRows - Whether TrajectoryLog contains prebuilt CSV rows.
arguments
    trajectoryLog (1, 1) struct
end

tf = isfield(trajectoryLog, 'CsvRows') && isfield(trajectoryLog, 'CsvRowCount') && ...
    trajectoryLog.CsvRowCount > 0;
end
