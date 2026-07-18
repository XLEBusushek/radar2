% testRoadGeneration - Проверяет процедурную генерацию дорожной сети (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
setScenarioRNG(config.sim.random.seed);

roadNetwork = generateRoadNetwork(config);
roads = roadNetwork.Roads;
countRange = config.roads.countRange;

assert(numel(roads) >= countRange(1) && numel(roads) <= countRange(2), ...
    'Road count must be within config.roads.countRange.');
assert(isfield(roadNetwork, 'Intersections'), 'RoadNetwork must have Intersections.');

for i = 1:numel(roads)
    road = roads(i);
    assert(isfield(road, 'ID') && road.ID == i, 'Road.ID must be set.');
    assert(isfield(road, 'Points') && size(road.Points, 2) == 3, 'Road.Points must be Nx3.');
    assert(road.Length > 0, 'Road.Length must be positive.');
    assert(road.Width >= config.roads.widthRange(1) && road.Width <= config.roads.widthRange(2), ...
        'Road.Width out of range.');
    assert(road.SpeedLimit >= config.roads.speedLimitRange(1) && ...
        road.SpeedLimit <= config.roads.speedLimitRange(2), 'Road.SpeedLimit out of range.');
    assert(isfield(road, 'Intersections'), 'Road.Intersections is required.');
end

for i = 1:numel(roadNetwork.Intersections)
    inter = roadNetwork.Intersections(i);
    assert(numel(inter.RoadIDs) == 2, 'Intersection must reference two roads.');
    assert(numel(inter.Position) == 3, 'Intersection position must be 3D.');
end

disp('testRoadGeneration passed.');
