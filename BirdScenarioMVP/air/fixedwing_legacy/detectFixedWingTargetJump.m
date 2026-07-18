function jump = detectFixedWingTargetJump(previousPoint, newPoint)
% detectFixedWingTargetJump - Расстояние по XY между точками навигации.
arguments
    previousPoint (:, 1) double
    newPoint (:, 1) double
end

if isempty(previousPoint) || isempty(newPoint) || ...
        numel(previousPoint) < 2 || numel(newPoint) < 2
    jump = 0;
    return;
end

jump = norm(newPoint(1:2) - previousPoint(1:2));
end
