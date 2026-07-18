function fig = plotVisibility(trajectoryLog, config)
% plotVisibility - Временная шкала видимости из TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
end

if ~shouldPlot(config, 'showVisibility', 'visibilityFigure')
    fig = [];
    return;
end

fig = figure('Name', 'BirdScenario - Visibility', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');

ids = getUniqueTargetIds(trajectoryLog);
for id = ids(:).'
    history = buildTargetHistoryFromLog(trajectoryLog, id);
    if isempty(history.Time)
        continue;
    end
    plot(ax, history.Time, double(history.Visible), '-', 'LineWidth', 1.2);
end

xlabel(ax, 'Time (s)');
ylabel(ax, 'Visible');
title(ax, 'Target visibility');
ylim(ax, [-0.1, 1.1]);
hold(ax, 'off');

saveAnalysisFigure(fig, config.analysis.visibilityFile, config);
if ~keepFiguresOpen(config)
    close(fig);
end
end

function tf = shouldPlot(config, showField, legacyField)
analysis = config.analysis;
if isfield(analysis, showField)
    tf = analysis.(showField);
elseif isfield(analysis, legacyField)
    tf = analysis.(legacyField);
else
    tf = false;
end
end

function tf = keepFiguresOpen(config)
tf = isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
    config.analysis.showFigures;
end
