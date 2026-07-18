% testAnalysisPlots - Проверяет функции построения аналитических графиков (ТЗ-06B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 15;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = true;
config.analysis.showFigures = false;
config.analysis.saveFigures = false;

[scenario, ~] = runSimulation(config);

figXY = plotXYTrajectories(scenario, config);
assert(~isempty(figXY) && isgraphics(figXY), 'plotXYTrajectories must return a figure.');
close(figXY);

figAlt = plotAltitudeTime(scenario, config);
assert(~isempty(figAlt) && isgraphics(figAlt), 'plotAltitudeTime must return a figure.');
close(figAlt);

figSpeed = plotSpeedTime(scenario, config);
assert(~isempty(figSpeed) && isgraphics(figSpeed), 'plotSpeedTime must return a figure.');
close(figSpeed);

figState = plotStateTimeline(scenario, config);
assert(~isempty(figState) && isgraphics(figState), 'plotStateTimeline must return a figure.');
close(figState);

figVis = plotVisibilityTimeline(scenario, config);
assert(~isempty(figVis) && isgraphics(figVis), 'plotVisibilityTimeline must return a figure.');
close(figVis);

plotAnalysisFigures(scenario, config);

disp('testAnalysisPlots passed.');
