function fixedWingUAVs = getScenarioFixedWingUAVs(scenario)
% getScenarioFixedWingUAVs - Вернуть цели fixed-wing UAV из структуры сценария.
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
