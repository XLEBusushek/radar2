function exportFromLog(trajectoryLog, config, env, legacyOutput)
% exportFromLog - Export TrajectoryLog to MAT, CSV, and figures.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
    env (1, 1) struct = struct()
    legacyOutput struct = struct([])
end

if ~isfield(config, 'export') || ~config.export.enabled
    return;
end

outputFolder = ensureOutputFolder(config);
legacyNeeded = needsLegacyOutputForExport(config, legacyOutput);

if legacyNeeded && isempty(legacyOutput)
    legacyOutput = trajectoryLogToLegacyOutput(trajectoryLog, config);
end

if config.export.saveMat
    exportMAT(trajectoryLog, legacyOutput, config, outputFolder);
end

if config.export.saveCsv
    if shouldExportCsvFromLog(config, legacyOutput)
        exportCsvFromLog(trajectoryLog, config, outputFolder);
    else
        exportCSV(legacyOutput, config, outputFolder);
    end
end

if isfield(config.export, 'fixedWingDebugCsv') && config.export.fixedWingDebugCsv
    if isempty(legacyOutput)
        legacyOutput = trajectoryLogToLegacyOutput(trajectoryLog, config);
    end
    exportFixedWingDebugCsv(legacyOutput, config, outputFolder);
end

if config.export.saveFigure
    keepOpen = isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
        config.analysis.showFigures;
    fig = plotScenarioFromLog(trajectoryLog, env, config);
    figPath = fullfile(outputFolder, config.export.figureFileName);
    saveFigureFile(fig, figPath, config);
    if ~keepOpen
        close(fig);
    end
end

if isfield(config, 'analysis') && config.analysis.enabled
    ensureAnalysisFigureFilesFromLog(trajectoryLog, env, config, outputFolder);
end
end
