% testQuadcopterForceDirect - Проверяет режим восстановления при отсутствии прогресса (ТЗ-07C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 1;
config.quadcopter.navigation.noProgressTimeLimit = 2;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
config.debug.verbose = false;

setScenarioRNG(config.sim.random.seed);
scenario = initializeScenario(config);
quad = getScenarioQuadcopters(scenario);
quad = quad(1);

quad.State = "Transit";
quad.Position = [250; 250; 80];
quad.Velocity = zeros(3, 1);
quad.Payload.CurrentWaypoint = [700; 250; 120];
quad.Payload.CurrentWaypointIndex = 1;
quad.Payload.Waypoints(1, :) = quad.Payload.CurrentWaypoint.';
quad.Payload.DistanceToWaypoint = norm(quad.Payload.CurrentWaypoint - quad.Position);
quad.Payload.PreviousDistanceToWaypoint = 1;
quad.Payload.NoProgressTime = config.quadcopter.navigation.noProgressTimeLimit + 1;

quad = updateQuadcopterNavigationProgress(quad, config, config.sim.dt);
assert(quad.Payload.ForceDirectToWaypoint, 'ForceDirectToWaypoint must activate.');

initialDistance = norm(quad.Payload.CurrentWaypoint - quad.Position);
quad.Payload.DesiredSpeed = mean(config.quadcopter.transitSpeedRange);
quad.Payload.DesiredAltitude = quad.Payload.CurrentWaypoint(3);
for step = 1:6 %#ok<NASGU>
    quad = updateQuadcopterMotionCommand(quad, config);
    quad = updateQuadcopterKinematics(quad, config, config.sim.dt);
end
finalDistance = norm(quad.Payload.CurrentWaypoint - quad.Position);

assert(finalDistance < initialDistance, 'ForceDirect mode must move toward waypoint.');

disp('testQuadcopterForceDirect passed.');
