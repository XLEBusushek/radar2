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

log.Time = zeros(0, 1);
log.Frames = struct([]);
end
