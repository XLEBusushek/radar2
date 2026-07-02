% testGroundVehicleRouteGeneration - Checks graph route creation (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 3;
rng(config.sim.seed);

scenario = initializeScenario(config);
vehicles = getScenarioGroundVehicles(scenario);
for i = 1:numel(vehicles)
    payload = vehicles(i).Payload;
    assert(isfield(payload, 'RoadRoute') && ~isempty(payload.RoadRoute.EdgeIDs), 'RoadRoute required.');
    assert(isfield(payload, 'RoutePoints') && size(payload.RoutePoints, 1) >= 2, 'RoutePoints required.');
    assert(payload.RoadRoute.Length >= config.ground.route.minRouteLength, 'Route too short.');
    assert(payload.RouteDestinationNodeID > 0, 'Destination node required.');
end

disp('testGroundVehicleRouteGeneration passed.');
