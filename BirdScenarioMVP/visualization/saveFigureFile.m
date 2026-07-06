function saveFigureFile(fig, filePath, config)
% saveFigureFile - Save a figure to PNG without blocking on UI refresh.
arguments
    fig
    filePath (1, :) char
    config (1, 1) struct = struct()
end

if ~isgraphics(fig, 'figure')
    error('saveFigureFile:InvalidFigure', 'A valid figure handle is required.');
end

resolution = getFigureResolution(config);
wasVisible = strcmp(fig.Visible, 'on');
set(fig, 'Visible', 'off');
deferDisplay = isfield(config, 'export') && isfield(config.export, 'deferScenarioFigureDisplay') && ...
    config.export.deferScenarioFigureDisplay;
try
    if exist('exportgraphics', 'file') == 2
        exportgraphics(fig, filePath, 'Resolution', resolution, ...
            'BackgroundColor', 'white', 'ContentType', 'image');
    else
        print(fig, filePath, '-dpng', sprintf('-r%d', resolution));
    end
catch
    print(fig, filePath, '-dpng', sprintf('-r%d', resolution));
end
if wasVisible && ~deferDisplay
    set(fig, 'Visible', 'on');
end
end

function resolution = getFigureResolution(config)
resolution = 150;
if isfield(config, 'export') && isfield(config.export, 'figureResolution')
    resolution = config.export.figureResolution;
end
end
