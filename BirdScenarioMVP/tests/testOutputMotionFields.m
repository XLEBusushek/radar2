% testOutputMotionFields - Проверяет поля движения в Output (ТЗ-05B).
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
config.birds.fsm.enabled = true;

[scenario, output] = runSimulation(config);

requiredFields = {'DesiredSpeed', 'DesiredVelocity', 'DesiredAltitude', ...
    'DistanceToTargetTree', 'ArrivedToTargetTree'};

for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        targetOut = output(k).Targets(i);

        for f = 1:numel(requiredFields)
            assert(isfield(targetOut, requiredFields{f}), ...
                'Output target must have field: %s.', requiredFields{f});
        end
    end
end

disp('testOutputMotionFields passed.');
