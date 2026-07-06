function scenario = updateScenario(scenario, config, dt)
% updateScenario - Advance scenario by one time step.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

scenario.Time = scenario.Time + dt;

if isfield(scenario, 'Targets') && ~isempty(scenario.Targets)
    for i = 1:numel(scenario.Targets)
        scenario.Targets(i) = updateTarget(scenario.Targets(i), scenario, config, dt);
    end
end

scenario = syncScenarioTargetViews(scenario);
end
