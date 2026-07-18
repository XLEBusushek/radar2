function runVisualization(trajectoryLog, env, config)
% runVisualization - Построение аналитических графиков только из TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    env (1, 1) struct
    config (1, 1) struct
end

if ~isfield(config, 'analysis') || ~config.analysis.enabled
    return;
end

analysis = config.analysis;
keepOpen = isfield(analysis, 'showFigures') && analysis.showFigures;

if shouldPlotAnalysisFigure(analysis, 'showXY', 'xyFigure')
    fig = plotTrajectories(trajectoryLog, env, config);
    saveAnalysisFigure(fig, analysis.xyFile, config);
    if ~keepOpen
        close(fig);
    end
end

plotAltitude(trajectoryLog, config);
plotVelocity(trajectoryLog, config);
plotStates(trajectoryLog, config);
plotVisibility(trajectoryLog, config);
end

function plotFlag = shouldPlotAnalysisFigure(analysis, newField, legacyField)
if isfield(analysis, newField)
    plotFlag = analysis.(newField);
elseif isfield(analysis, legacyField)
    plotFlag = analysis.(legacyField);
else
    plotFlag = false;
end
end
