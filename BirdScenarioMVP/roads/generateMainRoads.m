function roads = generateMainRoads(config)
% generateMainRoads - Generate long map-spanning main roads.
arguments
    config (1, 1) struct
end

cfg = config.roads;
count = randi(cfg.mainRoadCountRange);
roads = repmat(emptyRoad(), 1, count);
for i = 1:count
    control = mainRoadControlPoints(i, count, config);
    points = smoothRoadPolyline(control, config);
    roads(i).ID = i;
    roads(i).Points = points;
    roads(i).Length = computeRoadLength(points);
    roads(i).Width = sampleRange(cfg.mainRoadWidthRange);
    roads(i).Type = "main";
    roads(i).SpeedLimit = sampleRange(cfg.mainRoadSpeedLimitRange);
    roads(i).Intersections = [];
end
end

function control = mainRoadControlPoints(index, count, config)
world = config.world.size;
margin = config.roads.margin;
jitter = 120;
numControl = randi([4, 6]);
t = linspace(0, 1, numControl).';

switch mod(index - 1, 4)
    case 0
        yBase = margin + index / (count + 1) * (world(2) - 2 * margin);
        x = linspace(0, world(1), numControl).';
        y = yBase + (rand(numControl, 1) - 0.5) * 2 * jitter;
    case 1
        xBase = margin + index / (count + 1) * (world(1) - 2 * margin);
        x = xBase + (rand(numControl, 1) - 0.5) * 2 * jitter;
        y = linspace(0, world(2), numControl).';
    case 2
        x = t * world(1);
        y = (0.15 + 0.7 * t) * world(2) + (rand(numControl, 1) - 0.5) * 2 * jitter;
    otherwise
        x = t * world(1);
        y = (0.85 - 0.7 * t) * world(2) + (rand(numControl, 1) - 0.5) * 2 * jitter;
end

x = min(max(x, 0), world(1));
y = min(max(y, 0), world(2));
control = [x, y, zeros(numControl, 1)];
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
