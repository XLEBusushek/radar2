function varargout = runSimulation(config)
% runSimulation - Run simulation and record TrajectoryLog.
%   [scenario, output] = runSimulation(config) - legacy output (backward compatible).
%   [scenario, log, output] = runSimulation(config) - TrajectoryLog + legacy output.
arguments
    config (1, 1) struct
end

if ~isfield(config, 'sim') || ~isfield(config.sim, 'dt') || ~isfield(config.sim, 'duration')
    error('runSimulation:MissingConfig', 'config.sim.dt and config.sim.duration are required.');
end

randomState = initializeRandomSystem(config);
scenario = initializeScenario(config, randomState);
trajectoryLog = createTrajectoryLog(config, randomState);

dt = config.sim.dt;
duration = config.sim.duration;
timeVector = 0:dt:duration;
numSteps = numel(timeVector);

for k = 1:numSteps
    if k > 1
        scenario = updateScenario(scenario, config, dt);
    end
    trajectoryLog = logFrame(scenario, trajectoryLog, scenario.Time, config);
end

trajectoryLog = trimTrajectoryLog(trajectoryLog);

legacyOutput = struct([]);
if nargout >= 2
    legacyOutput = trajectoryLogToLegacyOutput(trajectoryLog, config);
end

switch nargout
    case 0
    case 1
        varargout{1} = scenario;
    case 2
        varargout{1} = scenario;
        varargout{2} = legacyOutput;
    otherwise
        varargout{1} = scenario;
        varargout{2} = trajectoryLog;
        varargout{3} = legacyOutput;
end

if isfield(config, 'debug') && isfield(config.debug, 'verbose') && config.debug.verbose
    fprintf('[%s] Simulation finished at t = %.1f s (%d steps).\n', ...
        config.project.name, scenario.Time, numSteps);
end
end
