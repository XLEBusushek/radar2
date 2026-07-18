% testHistoryUpdate - Проверяет историю целей за симуляцию (ТЗ-04).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 10;
config.sim.dt = 1;
config.birds.fsm.enabled = false;

[scenario, ~] = runSimulation(config);

expectedHistoryLength = floor(config.sim.duration / config.sim.dt) + 1;
expectedTime = (0:config.sim.dt:config.sim.duration)';

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;

    assert(numel(history.Time) == expectedHistoryLength, ...
        'History.Time length must match step count.');
    assert(size(history.Position, 1) == expectedHistoryLength, ...
        'History.Position row count must match step count.');
    assert(size(history.Velocity, 1) == expectedHistoryLength, ...
        'History.Velocity row count must match step count.');
    assert(size(history.Acceleration, 1) == expectedHistoryLength, ...
        'History.Acceleration row count must match step count.');
    assert(numel(history.State) == expectedHistoryLength, ...
        'History.State length must match step count.');
    assert(numel(history.Visible) == expectedHistoryLength, ...
        'History.Visible length must match step count.');
    assert(numel(history.RCS) == expectedHistoryLength, ...
        'History.RCS length must match step count.');

    assert(isequal(history.Time(:), expectedTime), ...
        'History.Time must match the simulation time vector.');

    if size(history.Position, 1) > 1
        assert(all(diff(history.Position, 1, 1) == 0, 'all'), ...
            'Bird position must remain constant across history.');
    end

    assert(all(history.Velocity(:) == 0), ...
        'History.Velocity must remain zero.');
    assert(all(history.Acceleration(:) == 0), ...
        'History.Acceleration must remain zero.');
    assert(all(history.State == "Perched"), ...
        'History.State must remain Perched.');
    assert(all(history.Visible == false), ...
        'History.Visible must remain false.');
end

disp('testHistoryUpdate passed.');
