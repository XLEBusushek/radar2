function tf = shouldPlotStateSegments(config)
% shouldPlotStateSegments - Whether bird trajectories use per-state 3D segments.
arguments
    config (1, 1) struct
end

tf = isfield(config, 'visualization') && config.visualization.showStateSegments;
end
