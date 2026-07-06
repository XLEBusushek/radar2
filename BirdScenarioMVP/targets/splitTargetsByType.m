function indices = splitTargetsByType(targets)
% splitTargetsByType - Index targets by class/subtype.
arguments
    targets (:, 1) struct
end

if isempty(targets)
    indices.Birds = [];
    indices.Quadcopters = [];
    indices.FixedWingUAVs = [];
    indices.GroundVehicles = [];
    return;
end

indices.Birds = find(arrayfun(@(t) t.Class == "bird", targets));
indices.Quadcopters = find(arrayfun(@(t) t.Class == "air" && t.Subtype == "quadcopter", targets));
indices.FixedWingUAVs = find(arrayfun(@(t) t.Class == "air" && t.Subtype == "fixedWingUAV", targets));
indices.GroundVehicles = find(arrayfun(@(t) t.Class == "ground", targets));
end
