% testFixedWingWaypointBoundaryMargin - Checks waypoint boundary margins (ТЗ-09D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 3;
setScenarioRNG(42);

scenario = initializeScenario(config);
fixedWing = getScenarioFixedWingUAVs(scenario);
margin = config.fixedWing.navigation.minWaypointBoundaryMargin;
worldSize = config.world.size;

for i = 1:numel(fixedWing)
    waypoints = fixedWing(i).Payload.Waypoints;
    assert(all(waypoints(:, 1) >= margin), 'Waypoint X below margin.');
    assert(all(waypoints(:, 1) <= worldSize(1) - margin), 'Waypoint X above margin.');
    assert(all(waypoints(:, 2) >= margin), 'Waypoint Y below margin.');
    assert(all(waypoints(:, 2) <= worldSize(2) - margin), 'Waypoint Y above margin.');
end

disp('testFixedWingWaypointBoundaryMargin passed.');
