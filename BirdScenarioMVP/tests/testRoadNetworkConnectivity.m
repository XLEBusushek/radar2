% testRoadNetworkConnectivity - Checks road graph connectivity (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
rng(config.sim.seed);
roadNetwork = generateRoadNetwork(config);
[isValid, report] = validateRoadNetwork(roadNetwork, config);

assert(isfield(roadNetwork, 'Nodes') && ~isempty(roadNetwork.Nodes), 'Nodes required.');
assert(isfield(roadNetwork, 'Edges') && ~isempty(roadNetwork.Edges), 'Edges required.');
assert(isfield(roadNetwork, 'Adjacency') && ~isempty(roadNetwork.Adjacency), 'Adjacency required.');
assert(report.ConnectedFraction >= config.roads.minConnectedFraction, ...
    'Biggest connected component must contain at least 90%% of edges.');
assert(report.IntersectionCount >= 3, 'Road network must have intersections.');
assert(isValid, 'Road network must pass validation.');

disp('testRoadNetworkConnectivity passed.');
