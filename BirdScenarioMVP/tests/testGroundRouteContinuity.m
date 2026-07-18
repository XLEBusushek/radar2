% testGroundRouteContinuity - Проверяет геометрию связного наземного маршрута (ТЗ-08B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 3;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
vehicles = getScenarioGroundVehicles(scenario);

for i = 1:numel(vehicles)
    route = vehicles(i).Payload.Route;
    assert(size(route.Points, 1) >= 2, 'Route must have at least two points.');
    assert(numel(route.RoadIDs) == size(route.Points, 1) - 1, ...
        'Route.RoadIDs must match route segment count.');
    assert(all(diff(route.CumulativeDistance) > 0), ...
        'Route cumulative distance must be strictly increasing.');
    for s = 1:numel(route.RoadIDs)
        road = getRoadByIDLocal(scenario.RoadNetwork, route.RoadIDs(s));
        midPoint = 0.5 * (route.Points(s, :) + route.Points(s + 1, :));
        assert(distanceToRoadLocal(midPoint, road) < 1e-6, ...
            'Each route segment must lie on its referenced road.');
    end
end

disp('testGroundRouteContinuity passed.');

function road = getRoadByIDLocal(roadNetwork, roadID)
idx = find([roadNetwork.Roads.ID] == roadID, 1, 'first');
road = roadNetwork.Roads(idx);
end

function d = distanceToRoadLocal(point, road)
d = inf;
for k = 1:(size(road.Points, 1) - 1)
    [proj, ~] = projectToSegmentLocal(point(1:2), road.Points(k, 1:2), road.Points(k + 1, 1:2));
    d = min(d, norm(proj(:).' - point(1:2)));
end
end

function [proj, frac] = projectToSegmentLocal(p, a, b)
ab = b - a;
den = dot(ab, ab);
if den <= 1e-9
    frac = 0;
else
    frac = dot(p - a, ab) / den;
end
frac = min(max(frac, 0), 1);
proj = a + frac * ab;
end
