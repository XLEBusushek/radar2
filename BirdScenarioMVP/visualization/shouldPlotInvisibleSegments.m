function tf = shouldPlotInvisibleSegments(config)
% shouldPlotInvisibleSegments - Whether to draw visible/invisible 3D segments.
arguments
    config (1, 1) struct
end

if isFast3DVisualization(config)
    tf = false;
    return;
end

tf = isfield(config, 'visualization') && config.visualization.showInvisibleSegments;
end
