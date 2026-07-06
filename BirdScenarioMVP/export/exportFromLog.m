function scenarioFig = exportFromLog(trajectoryLog, config, env, legacyOutput)
% exportFromLog - Export TrajectoryLog to MAT, CSV, and figures.
%   scenarioFig = exportFromLog(...) - optional 3D figure handle to show after export.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
    env (1, 1) struct = struct()
    legacyOutput struct = struct([])
end

scenarioFig = [];

if ~isfield(config, 'export') || ~config.export.enabled
    return;
end

outputFolder = ensureOutputFolder(config);
legacyNeeded = needsLegacyOutputForExport(config, legacyOutput);

if legacyNeeded && isempty(legacyOutput)
    legacyOutput = trajectoryLogToLegacyOutput(trajectoryLog, config);
end

exportTimer = tic;
keepScenarioOpen = isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
    config.analysis.showFigures;

if config.export.saveCsv
    stepTimer = tic;
    if shouldExportCsvFromLog(config, legacyOutput)
        exportCsvFromLog(trajectoryLog, config, outputFolder);
    else
        exportCSV(legacyOutput, config, outputFolder);
    end
    reportExportStep("CSV export done", stepTimer);
end

if isfield(config.export, 'fixedWingDebugCsv') && config.export.fixedWingDebugCsv
    stepTimer = tic;
    if isempty(legacyOutput)
        legacyOutput = trajectoryLogToLegacyOutput(trajectoryLog, config);
    end
    exportFixedWingDebugCsv(legacyOutput, config, outputFolder);
    reportExportStep("Fixed-wing debug CSV done", stepTimer);
end

if config.export.saveFigure
    stepTimer = tic;
    closeAllFigures();
    fig = plotScenarioFromLog(trajectoryLog, env, config);
    reportExportStep("3D figure built", stepTimer);
    figPath = fullfile(outputFolder, config.export.figureFileName);
    saveTimer = tic;
    saveFigureFile(fig, figPath, config);
    reportExportStep("3D PNG saved", saveTimer);
    if keepScenarioOpen
        scenarioFig = fig;
    else
        close(fig);
    end
end

if config.export.saveMat
    stepTimer = tic;
    exportMAT(trajectoryLog, legacyOutput, config, outputFolder);
    reportExportStep("MAT export done", stepTimer);
end

if shouldEnsureAnalysisFigureFiles(config)
    ensureAnalysisFigureFilesFromLog(trajectoryLog, env, config, outputFolder);
end

reportExportStep("Export finished", exportTimer);
end

function tf = shouldEnsureAnalysisFigureFiles(config)
if ~isfield(config, 'analysis') || ~config.analysis.enabled || ...
        ~config.analysis.saveFigures
    tf = false;
    return;
end
if isfield(config, 'export') && isfield(config.export, 'analysisFiguresAlreadySaved') && ...
        config.export.analysisFiguresAlreadySaved
    tf = false;
    return;
end
tf = true;
end
