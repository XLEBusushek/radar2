function tf = shouldExportCsvFromLog(config, legacyOutput)
% shouldExportCsvFromLog - Использовать быстрый путь TrajectoryLog для экспорта CSV.
arguments
    config (1, 1) struct
    legacyOutput struct = struct([])
end

csvFromLog = true;
if isfield(config, 'export') && isfield(config.export, 'csvFromLog')
    csvFromLog = logical(config.export.csvFromLog);
end

if ~csvFromLog
    tf = false;
    return;
end

if isempty(legacyOutput)
    tf = true;
else
    tf = csvFromLog;
end
end
