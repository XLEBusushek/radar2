% testFW2LegProgress - Прогресс участка растёт и завершается (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 1;
config.fixedWing.count = 0;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 550;
config.sim.dt = 1;
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

progress = uav.History.CurrentLegProgress;
assert(any(diff(progress) > 0), 'Leg progress must increase.');
assert(any(progress >= 0.5), 'Leg progress must advance significantly.');
assert(any(uav.History.RouteIndex > 1), 'Route index must advance.');
assert(~any(string(uav.History.State) == "Hover"), 'No hover state.');

disp('testFW2LegProgress passed.');
