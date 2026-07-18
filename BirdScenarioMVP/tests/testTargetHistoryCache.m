% testTargetHistoryCache - Кэшированные истории должны совпадать с прямой пересборкой.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.sim.duration = 10;
config.sim.dt = 1;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(42);

[~, trajectoryLog, ~] = runSimulation(config);
trajectoryLog = attachTargetHistoryCache(trajectoryLog);

ids = getUniqueTargetIds(trajectoryLog);
assert(~isempty(ids), 'Expected target IDs in log.');

for id = ids(:).'
    direct = buildTargetHistoryFromLog(struct('Frames', trajectoryLog.Frames, ...
        'FrameCount', trajectoryLog.FrameCount), id);
    cached = buildTargetHistoryFromLog(trajectoryLog, id);
    assert(isequal(direct.Time, cached.Time), 'Time mismatch for ID %d.', id);
    assert(isequaln(direct.Position, cached.Position), 'Position mismatch for ID %d.', id);
    assert(isequal(string(direct.State), string(cached.State)), 'State mismatch for ID %d.', id);
end

disp('testTargetHistoryCache passed.');
