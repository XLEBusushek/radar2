function [distanceToBoundary, outside] = computeDistanceToWorldBoundary(position, worldSize)
% computeDistanceToWorldBoundary - Minimum XY distance to world bounds.
arguments
    position (3, 1) double
    worldSize (1, 3) double
end

pos = position(:);
distances = [pos(1), worldSize(1) - pos(1), pos(2), worldSize(2) - pos(2)];
distanceToBoundary = min(distances);
outside = pos(1) < 0 || pos(1) > worldSize(1) || pos(2) < 0 || pos(2) > worldSize(2);
end
