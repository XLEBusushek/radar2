function birds = getScenarioBirds(scenario)
% getScenarioBirds - Return bird targets from a scenario struct.
arguments
    scenario (1, 1) struct
end

if isfield(scenario, 'Birds') && ~isempty(scenario.Birds)
    birds = scenario.Birds;
    return;
end

if isfield(scenario, 'Targets') && ~isempty(scenario.Targets)
    birdMask = arrayfun(@(t) t.Class == "bird", scenario.Targets);
    birds = scenario.Targets(birdMask);
else
    birds = struct([]);
end
end
