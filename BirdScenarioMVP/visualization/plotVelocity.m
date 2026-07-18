function fig = plotVelocity(trajectoryLog, config)
% plotVelocity - Скорость относительно времени из TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
end

if ~shouldPlot(config, 'showSpeed', 'speedFigure')
    fig = [];
    return;
end

fig = figure('Name', 'BirdScenario - Speed', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');

plotLogSeries(ax, trajectoryLog, "bird", "", '-', [0.85, 0.1, 0.1], @speedSeries);
plotLogSeries(ax, trajectoryLog, "air", "quadcopter", '--', [0.1, 0.4, 0.9], @speedSeries);
plotLogSeries(ax, trajectoryLog, "air", "fixedWingUAV", '-.', [0.45, 0.15, 0.75], @speedSeries);

xlabel(ax, 'Time (s)');
ylabel(ax, 'Speed (m/s)');
title(ax, 'Speed vs time');
addStandardBirdLegend2D(ax);
hold(ax, 'off');

saveAnalysisFigure(fig, config.analysis.speedFile, config);
if ~keepFiguresOpen(config)
    close(fig);
end
end

function y = speedSeries(history)
y = vecnorm(history.Velocity, 2, 2);
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
