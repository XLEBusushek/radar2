function road = generateRoad(id, config)
% generateRoad - Генерация одной относительно гладкой полилинии дороги в пределах мира.
arguments
    id (1, 1) {mustBePositive, mustBeInteger}
    config (1, 1) struct
end

worldSize = config.world.size;
roadsCfg = config.roads;
margin = getFieldOrDefault(roadsCfg, 'margin', 50);
lengthTarget = sampleRange(roadsCfg.lengthRange);
numSegments = randi([2, 5]);

startXY = [ ...
    margin + rand() * max(1, worldSize(1) - 2 * margin), ...
    margin + rand() * max(1, worldSize(2) - 2 * margin)];
heading = 2 * pi * rand();
points = zeros(numSegments + 1, 3);
points(1, :) = [startXY, 0];

remaining = lengthTarget;
for i = 2:(numSegments + 1)
    segLength = max(40, remaining / (numSegments - i + 2));
    heading = heading + deg2rad(-30 + 60 * rand());
    xy = points(i - 1, 1:2) + segLength * [cos(heading), sin(heading)];
    xy(1) = min(max(xy(1), 0), worldSize(1));
    xy(2) = min(max(xy(2), 0), worldSize(2));
    points(i, :) = [xy, 0];
    remaining = max(0, remaining - norm(points(i, 1:2) - points(i - 1, 1:2)));
end

road.ID = id;
road.Points = removeDuplicatePoints(points);
road.Length = computePolylineLength(road.Points);
road.Width = sampleRange(roadsCfg.widthRange);
road.Type = selectRoadType();
road.SpeedLimit = sampleRange(roadsCfg.speedLimitRange);
road.Intersections = [];
end

function points = removeDuplicatePoints(points)
if size(points, 1) <= 1
    return;
end
keep = [true; vecnorm(diff(points(:, 1:2), 1, 1), 2, 2) > 1e-6];
points = points(keep, :);
end

function len = computePolylineLength(points)
if size(points, 1) < 2
    len = 0;
else
    len = sum(vecnorm(diff(points(:, 1:2), 1, 1), 2, 2));
end
end

function value = sampleRange(range)
value = range(1) + rand() * (range(2) - range(1));
end

function roadType = selectRoadType()
types = ["dirt", "field", "service", "main"];
roadType = types(randi(numel(types)));
end

function value = getFieldOrDefault(s, fieldName, defaultValue)
if isfield(s, fieldName)
    value = s.(fieldName);
else
    value = defaultValue;
end
end
