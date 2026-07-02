function [scenario, output] = runSimulation(config)
% runSimulation - Run the bird scenario simulation over the full time horizon.
arguments
    config (1, 1) struct
end

if ~isfield(config, 'sim') || ~isfield(config.sim, 'dt') || ~isfield(config.sim, 'duration')
    error('runSimulation:MissingConfig', 'config.sim.dt and config.sim.duration are required.');
end

randomState = initializeRandomSystem(config);

scenario = initializeScenario(config, randomState);

dt = config.sim.dt;
duration = config.sim.duration;
timeVector = 0:dt:duration;
numSteps = numel(timeVector);

for k = 1:numSteps
    if k > 1
        scenario = updateScenario(scenario, config, dt);
    end
    output(k) = collectOutput(scenario, scenario.Time);
end

if isfield(config, 'debug') && isfield(config.debug, 'verbose') && config.debug.verbose
    fprintf('[%s] Simulation finished at t = %.1f s (%d steps).\n', ...
        config.project.name, scenario.Time, numSteps);
end
end
