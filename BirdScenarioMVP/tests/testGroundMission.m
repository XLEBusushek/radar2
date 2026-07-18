% testGroundMission - Проверяет привязанные к дороге waypoints миссии (ТЗ-08A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 3;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
groundVehicles = getScenarioGroundVehicles(scenario);
wpRange = config.groundVehicle.waypointCountRange;

for i = 1:numel(groundVehicles)
    vehicle = groundVehicles(i);
    waypoints = vehicle.Payload.Waypoints;
    assert(size(waypoints, 1) >= wpRange(1) && size(waypoints, 1) <= wpRange(2), ...
        'Ground waypoint count out of range.');
    assert(numel(vehicle.Payload.WaypointRoadIDs) == size(waypoints, 1), ...
        'Each waypoint must have a RoadID.');
    for w = 1:size(waypoints, 1)
        nearest = findNearestRoad(waypoints(w, :).', scenario.RoadNetwork);
        assert(nearest.Distance < 1e-6, 'Ground waypoint must lie on a road.');
        assert(any([scenario.RoadNetwork.Roads.ID] == vehicle.Payload.WaypointRoadIDs(w)), ...
            'Waypoint RoadID must reference an existing road.');
    end
end

disp('testGroundMission passed.');
