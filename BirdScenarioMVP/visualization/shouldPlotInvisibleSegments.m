function tf = shouldPlotInvisibleSegments(config)
% shouldPlotInvisibleSegments - Whether to draw visible/invisible 3D segments.
arguments
    config (1, 1) struct
end

tf = isfield(config, 'visualization') && config.visualization.showInvisibleSegments;
end
