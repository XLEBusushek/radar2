% testBehaviorRandomness - Проверяет, что разные seed дают разное поведение (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

configA = defaultConfig();
configA.behavior.enabled = true;
configA.behavior.decisionPeriodRange = [0.5, 0.5];
configA.birds.realism.enabled = false;
configA.sim.duration = 40;
configA.sim.dt = 1;
configA.sim.seed = 11;

configB = configA;
configB.sim.seed = 12;

[scenarioA, ~] = runSimulation(configA);
[scenarioB, ~] = runSimulation(configB);

targetA = scenarioA.Targets(1);
targetB = scenarioB.Targets(1);

samePosition = isequal(round(targetA.History.Position, 6), round(targetB.History.Position, 6));
sameBehavior = isequal(string(targetA.History.BehaviorAction), ...
    string(targetB.History.BehaviorAction));

assert(~samePosition || ~sameBehavior, ...
    'Different seeds must produce different trajectories or behavior decisions.');

disp('testBehaviorRandomness passed.');
