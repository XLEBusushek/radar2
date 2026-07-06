function tf = isFast3DVisualization(config)
% isFast3DVisualization - Whether to use lightweight 3D scenario rendering.
arguments
    config (1, 1) struct
end

if isfield(config, 'visualization') && isfield(config.visualization, 'fast3D')
    tf = logical(config.visualization.fast3D);
else
    tf = false;
end
end
