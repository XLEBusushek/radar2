function tf = shouldPlotInvisibleSegments(config)
% shouldPlotInvisibleSegments - Определяет, нужно ли рисовать видимые/невидимые 3D-сегменты.
arguments
    config (1, 1) struct
end

tf = isfield(config, 'visualization') && config.visualization.showInvisibleSegments;
end
