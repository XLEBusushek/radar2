function log = createTrajectoryLog(config, randomState)
% createTrajectoryLog - Initialize empty trajectory log.
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
end

function tf = shouldPreallocateFrames(config)
if isfield(config, 'log') && isfield(config.log, 'preallocateFrames')
    tf = logical(config.log.preallocateFrames);
else
    tf = true;
end
end
