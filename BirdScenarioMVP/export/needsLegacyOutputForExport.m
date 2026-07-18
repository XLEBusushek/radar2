function tf = needsLegacyOutputForExport(config, legacyOutput)
% needsLegacyOutputForExport - Требуется ли экспорту пересборка legacy.
arguments
    config (1, 1) struct
    legacyOutput struct = struct([])
end

if ~isempty(legacyOutput)
    tf = false;
    return;
end

needsMatLegacy = config.export.saveMat && shouldMatIncludeLegacy(config);
needsCsvLegacy = config.export.saveCsv && ~shouldExportCsvFromLog(config, legacyOutput);
needsDebugLegacy = isfield(config.export, 'fixedWingDebugCsv') && ...
    config.export.fixedWingDebugCsv;

tf = needsMatLegacy || needsCsvLegacy || needsDebugLegacy;
end

function tf = shouldMatIncludeLegacy(config)
if isfield(config.export, 'matIncludesLegacy')
    tf = logical(config.export.matIncludesLegacy);
else
    tf = false;
end
end
