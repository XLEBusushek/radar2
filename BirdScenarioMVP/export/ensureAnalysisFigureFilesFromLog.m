function ensureAnalysisFigureFilesFromLog(trajectoryLog, env, config, outputFolder)
% ensureAnalysisFigureFilesFromLog - Убедиться, что PNG-файлы анализа существуют из лога.
arguments
    trajectoryLog (1, 1) struct
    env (1, 1) struct
    config (1, 1) struct
    outputFolder (1, :) char
end

if ~isfield(config, 'analysis') || ~config.analysis.enabled || ...
        ~config.analysis.saveFigures
    return;
end

analysis = config.analysis;
fileMap = {
    shouldPlotAnalysisFigure(analysis, 'showXY', 'xyFigure'), analysis.xyFile, @() plotTrajectories(trajectoryLog, env, config)
    shouldPlotAnalysisFigure(analysis, 'showAltitude', 'altitudeFigure'), analysis.altitudeFile, @() plotAltitude(trajectoryLog, config)
    shouldPlotAnalysisFigure(analysis, 'showSpeed', 'speedFigure'), analysis.speedFile, @() plotVelocity(trajectoryLog, config)
    shouldPlotAnalysisFigure(analysis, 'showStates', 'stateFigure'), analysis.stateFile, @() plotStates(trajectoryLog, config)
    shouldPlotAnalysisFigure(analysis, 'showVisibility', 'visibilityFigure'), analysis.visibilityFile, @() plotVisibility(trajectoryLog, config)
};

for i = 1:size(fileMap, 1)
    if ~fileMap{i, 1}
        continue;
    end
    filePath = fullfile(outputFolder, char(fileMap{i, 2}));
    if isfile(filePath)
        continue;
    end
    fig = fileMap{i, 3}();
    if isempty(fig) || ~isgraphics(fig)
        continue;
    end
    saveAnalysisFigure(fig, fileMap{i, 2}, config);
    close(fig);
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
