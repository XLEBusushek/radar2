function exportScenarioResults(scenario, output, config)
% exportScenarioResults - Legacy export entry point (backward compatible).
arguments
    scenario (1, 1) struct
    output struct
    config (1, 1) struct
end

if ~isfield(config, 'export') || ~config.export.enabled
    return;
end

outputFolder = ensureOutputFolder(config);

if config.export.saveMat
    exportOutputToMat(scenario, output, config, outputFolder);
end

if config.export.saveCsv
    exportOutputToCsv(output, config, outputFolder);
end

if isfield(config.export, 'fixedWingDebugCsv') && config.export.fixedWingDebugCsv
    exportFixedWingDebugCsv(output, config, outputFolder);
end

if config.export.saveFigure
    keepOpen = isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
        config.analysis.showFigures;
    fig = plotScenario(scenario, config);
    figPath = fullfile(outputFolder, config.export.figureFileName);
    saveas(fig, figPath);
    if ~keepOpen
        close(fig);
    end
end

if isfield(config, 'analysis') && config.analysis.enabled
    ensureAnalysisFigureFiles(scenario, config, outputFolder);
end
end
