% testMixedAirTargets - Проверяет квадрокоптеры и fixed-wing UAV вместе (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.groundVehicle.count = 0;
config.quadcopter.count = 2;
config.fixedWing2.enabled = true;
config.fixedWing2.count = 2;
config.fixedWing.count = 0;
config.sim.duration = 30;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
quadcopters = getScenarioQuadcopters(scenario);
fixedWing = getScenarioFixedWingUAVs(scenario);

assert(numel(quadcopters) == config.quadcopter.count, 'Quadcopter count mismatch.');
assert(numel(fixedWing) == config.fixedWing2.count, 'Fixed-wing count mismatch.');
assert(any(arrayfun(@(t) t.Subtype == "quadcopter", scenario.Targets)), ...
    'Scenario must contain quadcopters.');
assert(any(arrayfun(@(t) t.Subtype == "fixedWingUAV", scenario.Targets)), ...
    'Scenario must contain fixed-wing UAVs.');

quadSpeeds = [];
for i = 1:numel(quadcopters)
    quadSpeeds = [quadSpeeds; vecnorm(quadcopters(i).History.Velocity, 2, 2)]; %#ok<AGROW>
end
fixedSpeeds = [];
for i = 1:numel(fixedWing)
    fixedSpeeds = [fixedSpeeds; vecnorm(fixedWing(i).History.Velocity, 2, 2)]; %#ok<AGROW>
end

assert(mean(fixedSpeeds) > mean(quadSpeeds), 'Fixed-wing UAVs should fly faster on average.');
assert(~any(string(fixedWing(1).History.State) == "Hover"), 'Fixed-wing UAV must not hover.');

disp('testMixedAirTargets passed.');
