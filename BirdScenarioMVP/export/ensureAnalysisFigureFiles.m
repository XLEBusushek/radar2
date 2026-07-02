function ensureAnalysisFigureFiles(scenario, config, outputFolder)
% ensureAnalysisFigureFiles - Ensure analysis PNG files exist in output folder.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
    outputFolder (1, :) char
end

if ~isfield(config, 'analysis') || ~config.analysis.enabled || ...
        ~config.analysis.saveFigures
    return;
end

analysis = config.analysis;
fileMap = {
    analysis.xyFigure, analysis.xyFile, @() plotXYTrajectories(scenario, config)
    analysis.altitudeFigure, analysis.altitudeFile, @() plotAltitudeTime(scenario, config)
    analysis.speedFigure, analysis.speedFile, @() plotSpeedTime(scenario, config)
    analysis.stateFigure, analysis.stateFile, @() plotStateTimeline(scenario, config)
    analysis.visibilityFigure, analysis.visibilityFile, @() plotVisibilityTimeline(scenario, config)
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
    saveAnalysisFigure(fig, fileMap{i, 2}, config);
    close(fig);
end
end
