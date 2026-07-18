% testBehaviorRepeatability - Проверяет воспроизводимость поведения при одинаковом seed (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.behavior.decisionPeriodRange = [0.5, 0.5];
config.birds.realism.enabled = false;
config.sim.duration = 35;
config.sim.dt = 1;
config.sim.seed = 21;

[scenarioA, ~] = runSimulation(config);
[scenarioB, ~] = runSimulation(config);

for i = 1:numel(scenarioA.Targets)
    a = scenarioA.Targets(i);
    b = scenarioB.Targets(i);

    assert(isequal(round(a.History.Position, 6), round(b.History.Position, 6)), ...
        'Positions must match for same seed.');
    assert(isequal(string(a.History.State), string(b.History.State)), ...
        'States must match for same seed.');
    assert(isequal(string(a.History.BehaviorAction), string(b.History.BehaviorAction)), ...
        'BehaviorAction must match for same seed.');
end

disp('testBehaviorRepeatability passed.');
