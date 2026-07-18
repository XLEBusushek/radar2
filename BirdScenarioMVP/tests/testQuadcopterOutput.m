% testQuadcopterOutput - Проверяет выходные поля квадрокоптера (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 2;
config.birds.count = 0;
config.sim.duration = 30;
config.sim.dt = 1;

[~, output] = runSimulation(config);

requiredFields = {'WaypointIndex', 'DistanceToWaypoint', 'MissionComplete', ...
    'HomePosition', 'CurrentWaypoint'};

for k = 1:numel(output)
    step = output(k);
    for i = 1:numel(step.Targets)
        t = step.Targets(i);
        if t.Class ~= "air"
            continue;
        end
        for f = 1:numel(requiredFields)
            assert(isfield(t, requiredFields{f}), 'Missing field: %s.', requiredFields{f});
        end
        assert(numel(t.HomePosition) == 3, 'HomePosition must be 3x1.');
        assert(numel(t.CurrentWaypoint) == 3, 'CurrentWaypoint must be 3x1.');
    end
end

disp('testQuadcopterOutput passed.');
