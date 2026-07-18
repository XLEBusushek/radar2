% testGroundVehicleNoFieldCutting - Проверяет, что траектория остаётся близко к маршруту (ТЗ-08C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 1;
config.groundVehicle.fsm.drive.stopProbability = 0;
config.groundVehicle.fsm.drive.leaveRoadProbability = 0;
config.sim.duration = 100;
config.sim.dt = 1;
rng(config.sim.seed);

[scenario, ~] = runSimulation(config);
vehicle = getScenarioGroundVehicles(scenario);
vehicle = vehicle(1);
pos = vehicle.History.Position;
route = vehicle.Payload.Route;

maxRouteDistance = 0;
for i = 1:size(pos, 1)
    projection = projectGroundRoute(pos(i, :).', route, 0);
    maxRouteDistance = max(maxRouteDistance, projection.DistanceToRoute);
end

straightDistance = norm(pos(end, 1:2) - pos(1, 1:2));
travelDistance = sum(vecnorm(diff(pos(:, 1:2), 1, 1), 2, 2));
assert(maxRouteDistance < 3 * config.groundVehicle.roadDeviationTolerance, ...
    'Vehicle trajectory must stay close to route.');
assert(travelDistance >= 0.85 * straightDistance, 'Vehicle movement must not teleport/cut directly.');

disp('testGroundVehicleNoFieldCutting passed.');
