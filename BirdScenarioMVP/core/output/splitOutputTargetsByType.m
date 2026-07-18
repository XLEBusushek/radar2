function outputStep = splitOutputTargetsByType(outputStep)
% splitOutputTargetsByType - Сформировать типизированные срезы целей из outputStep.Targets.
birdMask = arrayfun(@(t) t.Class == "bird", outputStep.Targets);
if any(birdMask)
    outputStep.Birds = outputStep.Targets(birdMask);
else
    outputStep.Birds = struct([]);
end

groundMask = arrayfun(@(t) t.Class == "ground", outputStep.Targets);
if any(groundMask)
    outputStep.GroundVehicles = outputStep.Targets(groundMask);
else
    outputStep.GroundVehicles = struct([]);
end

fixedWingMask = arrayfun(@(t) t.Class == "air" && t.Subtype == "fixedWingUAV", outputStep.Targets);
if any(fixedWingMask)
    outputStep.FixedWingUAVs = outputStep.Targets(fixedWingMask);
else
    outputStep.FixedWingUAVs = struct([]);
end
end
