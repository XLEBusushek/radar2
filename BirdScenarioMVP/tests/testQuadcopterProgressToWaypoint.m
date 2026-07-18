% testQuadcopterProgressToWaypoint - Проверяет приближение Transit к waypoint (ТЗ-07C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
config.debug.verbose = false;

setScenarioRNG(config.sim.random.seed);
scenario = initializeScenario(config);
quad = getScenarioQuadcopters(scenario);
quad = quad(1);

quad.State = "Transit";
quad.TimeInState = 0;
quad.CurrentTime = 0;
quad.Position = [300; 300; 80];
quad.Velocity = zeros(3, 1);
quad.Acceleration = zeros(3, 1);
quad.Payload.CurrentWaypoint = [650; 450; 140];
quad.Payload.CurrentWaypointIndex = 1;
quad.Payload.Waypoints(1, :) = quad.Payload.CurrentWaypoint.';
quad.Payload.DistanceToWaypoint = norm(quad.Payload.CurrentWaypoint - quad.Position);
quad.Payload.DesiredSpeed = mean(config.quadcopter.transitSpeedRange);
quad.Payload.DesiredAltitude = quad.Payload.CurrentWaypoint(3);

initialDistance = quad.Payload.DistanceToWaypoint;
for step = 1:8 %#ok<NASGU>
    quad = updateQuadcopterBehavior(quad, scenario, config, config.sim.dt);
    quad = updateQuadcopterKinematics(quad, config, config.sim.dt);
end
finalDistance = norm(quad.Payload.CurrentWaypoint - quad.Position);

assert(finalDistance < initialDistance, 'Transit must reduce distance to waypoint.');

disp('testQuadcopterProgressToWaypoint passed.');
