function scenario = syncScenarioTargetViews(scenario)
% syncScenarioTargetViews - Rebuild typed target views from scenario.Targets.
if ~isfield(scenario, 'Targets') || isempty(scenario.Targets)
    scenario.Birds = struct([]);
    scenario.Quadcopters = struct([]);
    scenario.FixedWingUAVs = struct([]);
    scenario.GroundVehicles = struct([]);
    return;
end

if ~isfield(scenario, 'TargetIndices') || isempty(fieldnames(scenario.TargetIndices))
    scenario.TargetIndices = splitTargetsByType(scenario.Targets);
end

indices = scenario.TargetIndices;
scenario.Birds = scenario.Targets(indices.Birds);
scenario.Quadcopters = scenario.Targets(indices.Quadcopters);
scenario.FixedWingUAVs = scenario.Targets(indices.FixedWingUAVs);
scenario.GroundVehicles = scenario.Targets(indices.GroundVehicles);
end
