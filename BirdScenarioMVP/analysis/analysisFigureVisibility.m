function visible = analysisFigureVisibility(config)
% analysisFigureVisibility - Вернуть видимость графика для графиков анализа.
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
