% testRoadNetworkLength - Checks road graph length constraints (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
rng(config.sim.seed);
roadNetwork = generateRoadNetwork(config);

totalRoadLength = sum([roadNetwork.Roads.Length]);
mainLengths = [roadNetwork.Roads(string({roadNetwork.Roads.Type}) == "main").Length];

assert(totalRoadLength >= config.roads.minTotalLength, 'Total road length too short.');
assert(all([roadNetwork.Roads.Length] >= config.roads.minRoadLength), ...
    'Roads must not be short fragments.');
assert(numel(mainLengths) >= config.roads.mainRoadCountRange(1), 'Missing main roads.');
assert(any(mainLengths > 1000), 'At least one main road must be longer than 1000 m.');

disp('testRoadNetworkLength passed.');
