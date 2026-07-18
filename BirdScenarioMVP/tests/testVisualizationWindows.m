% testVisualizationWindows - Проверяет имена окон аналитических графиков (ТЗ-06C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 10;
config.sim.dt = 1;
config.visualization.enabled = true;
config.export.enabled = false;
config.analysis.enabled = true;
config.analysis.showFigures = true;
config.analysis.saveFigures = false;

[scenario, ~] = runSimulation(config);

plotScenario(scenario, config);
plotAnalysisFigures(scenario, config);

expectedNames = {
    'BirdScenario - 3D'
    'BirdScenario - Top View'
    'BirdScenario - Altitude'
    'BirdScenario - Speed'
    'BirdScenario - FSM States'
    'BirdScenario - Visibility'
};

figHandles = findall(0, 'Type', 'figure');
foundNames = {};
for i = 1:numel(figHandles)
    foundNames{end + 1} = get(figHandles(i), 'Name'); %#ok<AGROW>
end

for i = 1:numel(expectedNames)
    assert(any(strcmp(foundNames, expectedNames{i})), ...
        'Figure window must exist: %s.', expectedNames{i});
end

disp('testVisualizationWindows passed.');
