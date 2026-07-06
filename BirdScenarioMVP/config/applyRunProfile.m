function config = applyRunProfile(config, profileName)
% applyRunProfile - Apply interactive, batch, fast, or benchmark presets.
arguments
    config (1, 1) struct
    profileName (1, 1) string = "interactive"
end

switch lower(profileName)
    case "interactive"
        config.analysis.showFigures = true;
        config.analysis.saveFigures = true;
        config.export.enabled = true;
        config.log.historyMode = "minimal";
        config.log.buildLegacyOutput = false;
    case "batch"
        config.analysis.showFigures = false;
        config.analysis.saveFigures = true;
        config.export.enabled = true;
        config.log.historyMode = "minimal";
        config.log.buildLegacyOutput = false;
    case "fast"
        config.analysis.enabled = false;
        config.analysis.showFigures = false;
        config.export.enabled = false;
        config.sim.duration = min(config.sim.duration, 60);
        config.log.historyMode = "minimal";
        config.log.buildLegacyOutput = false;
    case "benchmark"
        config.analysis.enabled = false;
        config.export.enabled = false;
        config.visualization.enabled = false;
        config.debug.verbose = false;
        config.log.historyMode = "off";
        config.log.buildLegacyOutput = false;
    otherwise
        error('applyRunProfile:UnknownProfile', 'Unknown profile: %s.', profileName);
end
end
