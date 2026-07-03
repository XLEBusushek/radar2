function target = fw2_clampWorldPosition(target, config)
% fw2_clampWorldPosition - Keep position inside world and altitude limits.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

worldSize = config.world.size;
target.Position(1) = min(max(target.Position(1), 0), worldSize(1));
target.Position(2) = min(max(target.Position(2), 0), worldSize(2));
altRange = config.fixedWing2.altitudeProfile.levelRange;
target.Position(3) = min(max(target.Position(3), altRange(1)), altRange(2));
end
