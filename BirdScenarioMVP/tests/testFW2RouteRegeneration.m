% testFW2RouteRegeneration - Новый маршрут после завершения (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 1;
config.fixedWing.count = 0;
config.fixedWing2.behavior.routeRegenerateOnComplete = true;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 400;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(101);

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

assert(any(string(uav.History.LastFW2Event) == "newRoute"), 'New route must be generated.');
safe = fw2_getZoneBounds(config).SafeZone;
assert(all(uav.Payload.RoutePoints(:, 1) >= safe(1)), 'Regenerated route outside safe X.');
assert(all(uav.Payload.RoutePoints(:, 2) >= safe(3)), 'Regenerated route outside safe Y.');
assert(max(uav.History.Position(:, 1)) <= config.world.size(1), 'Must stay in world.');

disp('testFW2RouteRegeneration passed.');
