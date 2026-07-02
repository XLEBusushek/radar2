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

birdMask = arrayfun(@(t) t.Class == "bird", scenario.Targets);
scenario.Birds = scenario.Targets(birdMask);
quadcopterMask = arrayfun(@(t) t.Class == "air" && t.Subtype == "quadcopter", scenario.Targets);
scenario.Quadcopters = scenario.Targets(quadcopterMask);
fixedWingMask = arrayfun(@(t) t.Class == "air" && t.Subtype == "fixedWingUAV", scenario.Targets);
scenario.FixedWingUAVs = scenario.Targets(fixedWingMask);
groundMask = arrayfun(@(t) t.Class == "ground", scenario.Targets);
scenario.GroundVehicles = scenario.Targets(groundMask);
end
