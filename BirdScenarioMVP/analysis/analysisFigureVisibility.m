function visible = analysisFigureVisibility(config)
% analysisFigureVisibility - Return figure visibility for analysis plots.
arguments
    config (1, 1) struct = struct()
end

if isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
        config.analysis.showFigures
    visible = 'on';
else
    visible = 'off';
end
end
