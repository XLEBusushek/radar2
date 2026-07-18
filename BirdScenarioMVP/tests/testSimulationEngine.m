% testSimulationEngine - Проверяет цикл симуляции по времени (ТЗ-04).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.fixedWing.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 10;
config.sim.dt = 1;
config.birds.fsm.enabled = false;

[scenario, output] = runSimulation(config);

expectedSteps = floor(config.sim.duration / config.sim.dt) + 1;
assert(numel(output) == expectedSteps, ...
    'Output must contain one entry per simulation step.');
assert(scenario.Time == config.sim.duration, ...
    'scenario.Time must equal config.sim.duration.');
assert(numel(scenario.Targets) == config.birds.count, ...
    'Target count must match config.birds.count.');
assert(numel(scenario.Birds) == config.birds.count, ...
    'Bird count must match config.birds.count.');

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);

    assert(target.CurrentTime == config.sim.duration, ...
        'CurrentTime must equal simulation duration.');
    assert(target.TimeInState == config.sim.duration, ...
        'TimeInState must equal simulation duration.');
    assert(target.State == "Perched", 'State must remain Perched.');
    assert(target.Visible == false, 'Visible must remain false.');
end

disp('testSimulationEngine passed.');
