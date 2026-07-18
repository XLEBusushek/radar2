% testAnalysisExport - Проверяет экспорт аналитических графиков после main (ТЗ-06B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

outputFolder = fullfile(projectRoot, 'output');
analysisFiles = {
    'bird_xy.png'
    'bird_altitude.png'
    'bird_speed.png'
    'bird_states.png'
    'bird_visibility.png'
};

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 20;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = true;
config.export.outputFolder = outputFolder;
config.export.saveMat = false;
config.export.saveCsv = false;
config.export.saveFigure = false;
config.analysis.enabled = true;
config.analysis.saveFigures = true;
config.analysis.showFigures = false;

[scenario, output] = runSimulation(config);
plotAnalysisFigures(scenario, config);
exportScenarioResults(scenario, output, config);

for i = 1:numel(analysisFiles)
    filePath = fullfile(outputFolder, analysisFiles{i});
    assert(isfile(filePath), 'Analysis file must exist: %s.', analysisFiles{i});
end

disp('testAnalysisExport passed.');
