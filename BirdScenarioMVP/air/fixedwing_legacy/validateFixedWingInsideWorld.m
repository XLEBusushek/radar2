function inside = validateFixedWingInsideWorld(position, worldSize, tolerance)
% validateFixedWingInsideWorld - Проверить, остаётся ли XY-позиция внутри границ мира.
arguments
    position (3, 1) double
    worldSize (1, 3) double
    tolerance (1, 1) double = 0
end

pos = position(:);
inside = pos(1) >= -tolerance && pos(1) <= worldSize(1) + tolerance && ...
    pos(2) >= -tolerance && pos(2) <= worldSize(2) + tolerance && ...
    pos(3) >= 0 && pos(3) <= worldSize(3);
end
