% testFixedWingNoHover - Checks fixed-wing UAV never hovers (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 2;
config.sim.duration = 60;

[scenario, ~] = runSimulation(config);
fixedWing = getScenarioFixedWingUAVs(scenario);

for i = 1:numel(fixedWing)
    states = string(fixedWing(i).History.State);
    speeds = vecnorm(fixedWing(i).History.Velocity, 2, 2);
    assert(~any(states == "Hover"), 'Fixed-wing UAV must not enter Hover.');
    assert(all(speeds >= config.fixedWing.minSpeed - 0.5), 'Fixed-wing UAV speed below minSpeed.');
end

disp('testFixedWingNoHover passed.');
