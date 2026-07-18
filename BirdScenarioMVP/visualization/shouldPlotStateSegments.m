function tf = shouldPlotStateSegments(config)
% shouldPlotStateSegments - Определяет, используют ли траектории птиц 3D-сегменты по состояниям.
arguments
    config (1, 1) struct
end

tf = isfield(config, 'visualization') && config.visualization.showStateSegments;
end
