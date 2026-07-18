function groundVehicles = getScenarioGroundVehicles(scenario)
% getScenarioGroundVehicles - Вернуть наземные транспортные средства из структуры сценария.
arguments
    scenario (1, 1) struct
end

if ~isfield(scenario, 'Targets') || isempty(scenario.Targets)
    groundVehicles = struct([]);
    return;
end

groundMask = arrayfun(@(t) t.Class == "ground" && t.Subtype == "vehicle", scenario.Targets);
groundVehicles = scenario.Targets(groundMask);
end
