% testHistoryModeNone - historyMode "none" must not append per-step history.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

baseConfig = defaultConfig();
baseConfig.sim.random.mode = "deterministic";
baseConfig.sim.random.seed = 42;
baseConfig.behavior.enabled = false;
baseConfig.birds.realism.enabled = false;
baseConfig.sim.duration = 20;
baseConfig.sim.dt = 1;
baseConfig.export.enabled = false;
baseConfig.analysis.enabled = false;

configNone = baseConfig;
configNone.log.historyMode = "none";

configOff = baseConfig;
configOff.log.historyMode = "off";

[scenarioNone, ~, ~] = runSimulation(configNone);
[scenarioOff, ~, ~] = runSimulation(configOff);

for i = 1:numel(scenarioNone.Targets)
    a = scenarioNone.Targets(i);
    b = scenarioOff.Targets(i);
    assert(isequal(round(a.Position, 6), round(b.Position, 6)), ...
        'Position mismatch for target %d.', a.ID);
    assert(numel(a.History.Time) == 1, ...
        'historyMode=none must keep only initial history for target %d.', a.ID);
    assert(numel(b.History.Time) > 1, ...
        'historyMode=off must append core history for target %d.', a.ID);
end

disp('testHistoryModeNone passed.');
