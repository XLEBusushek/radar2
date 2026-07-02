% testFixedWingDiveRecover - Checks Dive -> Recover -> Cruise sequence (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.diveDurationRange = [3, 3];
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = transitionFixedWingState(uav(1), "Dive", "test", config);
uav = appendTargetHistory(uav);
startAltitude = uav.Position(3);

for k = 1:40
    uav = updateTarget(uav, scenario, config, config.sim.dt);
end

states = string(uav.History.State);
altitudes = uav.History.Position(:, 3);
assert(any(states == "Dive"), 'Dive state must occur.');
assert(any(states == "Recover"), 'Recover state must occur after Dive.');
assert(any(altitudes < startAltitude - 5), 'Altitude must decrease during Dive.');
assert(any(states == "Cruise"), 'UAV must return to Cruise after Recover.');

disp('testFixedWingDiveRecover passed.');
