function exportFromLog(trajectoryLog, config, env)
% exportFromLog - Export TrajectoryLog to MAT, CSV, and figures.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
    env (1, 1) struct = struct()
end

if ~isfield(config, 'export') || ~config.export.enabled
    return;
end

outputFolder = ensureOutputFolder(config);
legacyOutput = trajectoryLogToLegacyOutput(trajectoryLog, config);

if config.export.saveMat
    exportMAT(trajectoryLog, legacyOutput, config, outputFolder);
end

if config.export.saveCsv
    exportCSV(legacyOutput, config, outputFolder);
end

if isfield(config.export, 'fixedWingDebugCsv') && config.export.fixedWingDebugCsv
    exportFixedWingDebugCsv(legacyOutput, config, outputFolder);
end

if config.export.saveFigure
    keepOpen = isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
        config.analysis.showFigures;
    fig = plotScenarioFromLog(trajectoryLog, env, config);
    figPath = fullfile(outputFolder, config.export.figureFileName);
    saveas(fig, figPath);
    if ~keepOpen
        close(fig);
    end
end

if isfield(config, 'analysis') && config.analysis.enabled
    ensureAnalysisFigureFilesFromLog(trajectoryLog, env, config, outputFolder);
end
end
