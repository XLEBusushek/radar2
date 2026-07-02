function position = enforceWorldBounds(position, worldSize)
% enforceWorldBounds - Clamp position coordinates to world cube bounds.
position = position(:);

position(1) = min(max(position(1), 0), worldSize(1));
position(2) = min(max(position(2), 0), worldSize(2));
position(3) = min(max(position(3), 0), worldSize(3));
end
