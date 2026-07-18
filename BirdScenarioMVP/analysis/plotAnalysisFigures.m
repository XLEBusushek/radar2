function plotAnalysisFigures(scenario, config)
% plotAnalysisFigures - Построить и при необходимости сохранить все графики анализа.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
end

if ~isfield(config, 'analysis') || ~config.analysis.enabled
    return;
end

analysis = config.analysis;
keepOpen = isfield(analysis, 'showFigures') && analysis.showFigures;

if shouldPlotAnalysisFigure(analysis, 'showXY', 'xyFigure')
    fig = plotXYTrajectories(scenario, config);
    saveAnalysisFigure(fig, analysis.xyFile, config);
    if ~keepOpen
        close(fig);
    end
end

if shouldPlotAnalysisFigure(analysis, 'showAltitude', 'altitudeFigure')
    fig = plotAltitudeTime(scenario, config);
    saveAnalysisFigure(fig, analysis.altitudeFile, config);
    if ~keepOpen
        close(fig);
    end
end

if shouldPlotAnalysisFigure(analysis, 'showSpeed', 'speedFigure')
    fig = plotSpeedTime(scenario, config);
    saveAnalysisFigure(fig, analysis.speedFile, config);
    if ~keepOpen
        close(fig);
    end
end

if shouldPlotAnalysisFigure(analysis, 'showStates', 'stateFigure')
    fig = plotStateTimeline(scenario, config);
    saveAnalysisFigure(fig, analysis.stateFile, config);
    if ~keepOpen
        close(fig);
    end
end

if shouldPlotAnalysisFigure(analysis, 'showVisibility', 'visibilityFigure')
    fig = plotVisibilityTimeline(scenario, config);
    saveAnalysisFigure(fig, analysis.visibilityFile, config);
    if ~keepOpen
        close(fig);
    end
end

if isfield(analysis, 'fixedWingNavigationDebug') && analysis.fixedWingNavigationDebug && ...
        ~isempty(getScenarioFixedWingUAVs(scenario))
    fig = plotFixedWingNavigationDebug(scenario, config);
    debugFile = "fixed_wing_navigation_debug.png";
    if isfield(analysis, 'fixedWingNavigationDebugFile')
        debugFile = analysis.fixedWingNavigationDebugFile;
    end
    saveAnalysisFigure(fig, debugFile, config);
    if ~keepOpen
        close(fig);
    end
end
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
