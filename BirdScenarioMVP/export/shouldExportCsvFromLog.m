function tf = shouldExportCsvFromLog(config, legacyOutput)
% shouldExportCsvFromLog - Use TrajectoryLog fast path for CSV export.
arguments
    config (1, 1) struct
    legacyOutput struct = struct([])
end

if isempty(legacyOutput)
    tf = true;
    return;
end

if isfield(config, 'export') && isfield(config.export, 'csvFromLog')
    tf = logical(config.export.csvFromLog);
else
    tf = false;
end
end
