% testOutputFormat - Проверяет формат структуры Output (ТЗ-04).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 5;
config.sim.dt = 1;

[scenario, output] = runSimulation(config);

expectedSteps = floor(config.sim.duration / config.sim.dt) + 1;
assert(numel(output) == expectedSteps, ...
    'Output must contain duration/dt + 1 steps.');

requiredFields = {'ID', 'Class', 'Subtype', 'Position', 'Velocity', ...
    'Acceleration', 'StateMatrix', 'RCS', 'Visible', 'State', ...
    'Mission', 'TimeInState', 'CurrentTime'};

for k = 1:numel(output)
    step = output(k);

    assert(isfield(step, 'Time'), 'Output step must have Time.');
    assert(isfield(step, 'Targets'), 'Output step must have Targets.');
    assert(isfield(step, 'Birds'), 'Output step must have Birds.');
    assert(numel(step.Targets) == config.birds.count, ...
        'Targets count must match config.birds.count.');
    assert(numel(step.Birds) == config.birds.count, ...
        'Birds count must match config.birds.count.');

    for i = 1:numel(step.Targets)
        targetOut = step.Targets(i);

        for f = 1:numel(requiredFields)
            assert(isfield(targetOut, requiredFields{f}), ...
                'Output target must have field: %s.', requiredFields{f});
        end

        assert(isequal(size(targetOut.Position), [3, 1]), ...
            'Position must be 3x1.');
        assert(isequal(size(targetOut.Velocity), [3, 1]), ...
            'Velocity must be 3x1.');
        assert(isequal(size(targetOut.Acceleration), [3, 1]), ...
            'Acceleration must be 3x1.');
        assert(isequal(size(targetOut.StateMatrix), [3, 2]), ...
            'StateMatrix must be 3x2.');
        assert(targetOut.CurrentTime == step.Time, ...
            'CurrentTime must match output step Time.');
    end
end

disp('testOutputFormat passed.');
