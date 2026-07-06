function saveFigureFile(fig, filePath, config)
% saveFigureFile - Save a figure via exportgraphics or saveas fallback.
arguments
    fig
    filePath (1, :) char
    config (1, 1) struct = struct()
end

if ~isgraphics(fig, 'figure')
    error('saveFigureFile:InvalidFigure', 'A valid figure handle is required.');
end

resolution = getFigureResolution(config);
try
    if exist('exportgraphics', 'file') == 2
        exportgraphics(fig, filePath, 'Resolution', resolution, 'BackgroundColor', 'white');
    else
        saveas(fig, filePath);
    end
catch
    saveas(fig, filePath);
end
end

function resolution = getFigureResolution(config)
resolution = 150;
if isfield(config, 'export') && isfield(config.export, 'figureResolution')
    resolution = config.export.figureResolution;
end
if isfield(config, 'visualization') && isfield(config.visualization, 'fast3D') && ...
        config.visualization.fast3D
    resolution = min(resolution, 120);
end
end
