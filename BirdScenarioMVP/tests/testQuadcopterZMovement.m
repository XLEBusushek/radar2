% testQuadcopterZMovement - Проверяет значимые изменения высоты (ТЗ-07C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.birds.count = 0;
config.quadcopter.count = 5;
config.quadcopter.waypointCountRange = [5, 6];
config.quadcopter.fsm.idle.maxTime = 1;
config.quadcopter.fsm.idle.takeoffProbability = 1.0;
config.behavior.enabled = true;
config.behavior.decisionPeriodRange = [0.5, 0.5];
config.sim.duration = 240;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
config.debug.verbose = false;

[scenario, ~] = runSimulation(config);
quadcopters = getScenarioQuadcopters(scenario);

passed = false(numel(quadcopters), 1);
for i = 1:numel(quadcopters)
    z = quadcopters(i).History.Position(:, 3);
    passed(i) = max(z) - min(z) >= config.quadcopter.navigation.minAltitudeChange;
end

assert(mean(passed) >= 0.8, ...
    'At least 80%% of quadcopters must change altitude by minAltitudeChange.');

disp('testQuadcopterZMovement passed.');
