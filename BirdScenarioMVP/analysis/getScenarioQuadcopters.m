function quadcopters = getScenarioQuadcopters(scenario)
% getScenarioQuadcopters - Вернуть цели-квадрокоптеры из структуры сценария.
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
