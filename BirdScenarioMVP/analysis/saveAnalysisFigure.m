function saveAnalysisFigure(fig, fileName, config)
% saveAnalysisFigure - Save an analysis figure to the export output folder.
arguments
    fig
    fileName (1, 1) string
    config (1, 1) struct
end

if ~isfield(config, 'analysis') || ~config.analysis.saveFigures
    return;
end

outputFolder = ensureOutputFolder(config);
filePath = fullfile(outputFolder, char(fileName));

if ~isgraphics(fig, 'figure')
    error('saveAnalysisFigure:InvalidFigure', ...
        'A valid figure handle is required to save analysis output.');
end

saveFigureFile(fig, filePath, config);
end
