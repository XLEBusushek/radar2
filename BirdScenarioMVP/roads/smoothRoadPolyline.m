function points = smoothRoadPolyline(controlPoints, config)
% smoothRoadPolyline - Smooth road control points with pchip interpolation.
arguments
    controlPoints (:, 3) double
    config (1, 1) struct
end

if size(controlPoints, 1) < 2
    points = controlPoints;
    return;
end

controlPoints(:, 3) = 0;
t = [0; cumsum(vecnorm(diff(controlPoints(:, 1:2), 1, 1), 2, 2))];
if t(end) <= 0
    points = controlPoints(1, :);
    return;
end

sampleCount = max(12, ceil(t(end) / 40));
tq = linspace(0, t(end), sampleCount).';
x = interp1(t, controlPoints(:, 1), tq, 'pchip');
y = interp1(t, controlPoints(:, 2), tq, 'pchip');
world = config.world.size;
x = min(max(x, 0), world(1));
y = min(max(y, 0), world(2));
points = [x, y, zeros(sampleCount, 1)];
points = removeDuplicatePoints(points);
end

function points = removeDuplicatePoints(points)
if size(points, 1) <= 1
    return;
end
keep = [true; vecnorm(diff(points(:, 1:2), 1, 1), 2, 2) > 1e-6];
points = points(keep, :);
end
