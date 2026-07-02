function quadcopters = getScenarioQuadcopters(scenario)
% getScenarioQuadcopters - Return quadcopter targets from a scenario struct.
arguments
    scenario (1, 1) struct
end

if ~isfield(scenario, 'Targets') || isempty(scenario.Targets)
    quadcopters = struct([]);
    return;
end

quadMask = arrayfun(@(t) t.Class == "air" && t.Subtype == "quadcopter", scenario.Targets);
quadcopters = scenario.Targets(quadMask);
end
