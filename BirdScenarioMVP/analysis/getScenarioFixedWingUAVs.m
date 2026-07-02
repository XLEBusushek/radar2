function fixedWingUAVs = getScenarioFixedWingUAVs(scenario)
% getScenarioFixedWingUAVs - Return fixed-wing UAV targets from a scenario struct.
arguments
    scenario (1, 1) struct
end

if ~isfield(scenario, 'Targets') || isempty(scenario.Targets)
    fixedWingUAVs = struct([]);
    return;
end

mask = arrayfun(@(t) t.Class == "air" && t.Subtype == "fixedWingUAV", scenario.Targets);
fixedWingUAVs = scenario.Targets(mask);
end
