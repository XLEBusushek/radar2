function roads = generateSecondaryRoads(mainRoads, config)
% generateSecondaryRoads - Generate secondary roads attached to main roads.
arguments
    mainRoads (1, :) struct
    config (1, 1) struct
end

cfg = config.roads;
count = randi(cfg.secondaryRoadCountRange);
roads = repmat(emptyRoad(), 1, count);
nextId = numel(mainRoads) + 1;
for i = 1:count
    startRoad = mainRoads(randi(numel(mainRoads)));
    startPoint = samplePointOnPolyline(startRoad.Points);
    if rand() < 0.45 && numel(mainRoads) > 1
        endRoad = mainRoads(randi(numel(mainRoads)));
        endPoint = samplePointOnPolyline(endRoad.Points);
    else
        endPoint = makeBranchEndpoint(startPoint, config);
    end
    control = makeCurvedControl(startPoint, endPoint);
    points = smoothRoadPolyline(control, config);

    roads(i).ID = nextId + i - 1;
    roads(i).Points = points;
    roads(i).Length = computeRoadLength(points);
    roads(i).Width = sampleRange(cfg.secondaryRoadWidthRange);
    roads(i).Type = "secondary";
    if rand() < 0.2
        roads(i).Type = "dirt";
    end
    roads(i).SpeedLimit = sampleRange(cfg.secondaryRoadSpeedLimitRange);
    roads(i).Intersections = [];
end
end

function endpoint = makeBranchEndpoint(startPoint, config)
world = config.world.size;
len = sampleRange(config.roads.secondaryRoadLengthRange);
angle = 2 * pi * rand();
endpoint = startPoint + len * [cos(angle), sin(angle), 0];
endpoint(1) = min(max(endpoint(1), config.roads.margin), world(1) - config.roads.margin);
endpoint(2) = min(max(endpoint(2), config.roads.margin), world(2) - config.roads.margin);
endpoint(3) = 0;
end

function control = makeCurvedControl(startPoint, endPoint)
numControl = randi([3, 6]);
t = linspace(0, 1, numControl).';
straight = startPoint + t .* (endPoint - startPoint);
delta = endPoint(1:2) - startPoint(1:2);
if norm(delta) < 1e-6
    side = [0, 0];
else
    side = [-delta(2), delta(1)] / norm(delta);
end
amplitude = min(120, 0.15 * norm(delta));
curve = sin(pi * t) * (2 * rand() - 1) * amplitude;
control = straight;
control(:, 1:2) = control(:, 1:2) + curve .* side;
control(:, 3) = 0;
end

function point = samplePointOnPolyline(points)
lengths = vecnorm(diff(points(:, 1:2), 1, 1), 2, 2);
total = sum(lengths);
if total <= 0
    point = points(1, :);
    return;
end
s = rand() * total;
remaining = s;
idx = numel(lengths);
for i = 1:numel(lengths)
    if remaining <= lengths(i)
        idx = i;
        break;
    end
    remaining = remaining - lengths(i);
end
ratio = remaining / max(lengths(idx), 1e-9);
point = points(idx, :) + ratio * (points(idx + 1, :) - points(idx, :));
point(3) = 0;
end

function road = emptyRoad()
road.ID = 0;
road.Points = zeros(0, 3);
road.Length = 0;
road.Width = 0;
road.Type = "";
road.SpeedLimit = 0;
road.Intersections = [];
end

function value = sampleRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
