function log = createTrajectoryLog(config, randomState)
% createTrajectoryLog - Инициализировать пустой лог траектории.
arguments
    config (1, 1) struct
    randomState (1, 1) struct = struct()
end

log.SimulationInfo.Duration = config.sim.duration;
log.SimulationInfo.TimeStep = config.sim.dt;
log.SimulationInfo.Seed = nan;
log.SimulationInfo.RandomMode = "";
if ~isempty(fieldnames(randomState))
    if isfield(randomState, 'ScenarioSeed')
        log.SimulationInfo.Seed = randomState.ScenarioSeed;
    end
    if isfield(randomState, 'Mode')
        log.SimulationInfo.RandomMode = string(randomState.Mode);
    end
end

log.SimulationInfo.LegacyPerFrame = shouldStoreLegacyPerFrame(config);
log.FrameCount = 0;
log.PreallocatedFrameCapacity = 0;

if shouldPreallocateFrames(config)
    log.PreallocatedFrameCapacity = numel(0:config.sim.dt:config.sim.duration);
    log.Time = zeros(log.PreallocatedFrameCapacity, 1);
    log.Frames = struct([]);
else
    log.Time = zeros(0, 1);
    log.Frames = struct([]);
end

if shouldIncrementalCsv(config)
    log.CsvRowCount = 0;
    log.CsvRowCapacity = estimateCsvRowCapacity(config, log);
end
end

function capacity = estimateCsvRowCapacity(config, log)
numFrames = log.PreallocatedFrameCapacity;
if numFrames <= 0
    numFrames = numel(0:config.sim.dt:config.sim.duration);
end
capacity = numFrames * estimateConfiguredTargetCount(config);
end

function count = estimateConfiguredTargetCount(config)
count = 0;
sections = {'birds', 'quadcopter', 'groundVehicle'};
for i = 1:numel(sections)
    name = sections{i};
    if isfield(config, name) && isfield(config.(name), 'count')
        count = count + config.(name).count;
    end
end
if isfield(config, 'fixedWing2') && isfield(config.fixedWing2, 'enabled') && ...
        config.fixedWing2.enabled && isfield(config.fixedWing2, 'count')
    count = count + config.fixedWing2.count;
elseif isfield(config, 'fixedWing') && isfield(config.fixedWing, 'count')
    count = count + config.fixedWing.count;
end
count = max(count, 1);
end

function tf = shouldPreallocateFrames(config)
if isfield(config, 'log') && isfield(config.log, 'preallocateFrames')
    tf = logical(config.log.preallocateFrames);
else
    tf = true;
end
end
