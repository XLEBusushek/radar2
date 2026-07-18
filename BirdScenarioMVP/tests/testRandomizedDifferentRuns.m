% testRandomizedDifferentRuns - Randomized mode создаёт разные seed сценария.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "randomized";
config.sim.duration = 20;
config.sim.dt = 1;
config.analysis.showFigures = false;
config.export.enabled = false;

[scenarioA, ~] = runSimulation(config);
pause(0.02);
[scenarioB, ~] = runSimulation(config);

assert(scenarioA.Random.ScenarioSeed ~= scenarioB.Random.ScenarioSeed, ...
    'Randomized runs must use different scenario seeds.');

differentTrajectory = false;
for i = 1:min(numel(scenarioA.Targets), numel(scenarioB.Targets))
    if ~isequal(round(scenarioA.Targets(i).History.Position, 6), ...
            round(scenarioB.Targets(i).History.Position, 6))
        differentTrajectory = true;
        break;
    end
end

assert(differentTrajectory, 'Randomized runs should differ in at least one trajectory.');
disp('testRandomizedDifferentRuns passed.');
