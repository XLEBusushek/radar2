function len = computeRoadLength(points)
% computeRoadLength - Compute XY polyline length.
arguments
    points (:, 3) double
end

if size(points, 1) < 2
    len = 0;
else
    len = sum(vecnorm(diff(points(:, 1:2), 1, 1), 2, 2));
end
end
