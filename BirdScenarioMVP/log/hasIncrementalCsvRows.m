function tf = hasIncrementalCsvRows(trajectoryLog)
% hasIncrementalCsvRows - Содержит ли TrajectoryLog предварительно сформированные строки CSV.
arguments
    trajectoryLog (1, 1) struct
end

tf = isfield(trajectoryLog, 'CsvRows') && isfield(trajectoryLog, 'CsvRowCount') && ...
    trajectoryLog.CsvRowCount > 0;
end
