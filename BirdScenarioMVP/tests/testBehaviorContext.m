% testBehaviorContext - Checks required behavior context fields (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.realism.enabled = false;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
requiredFields = {'Time', 'State', 'Class', 'Subtype', 'Position', 'Speed', ...
    'Altitude', 'TimeInState', 'CurrentGoal', 'DistanceToTarget', ...
    'DistanceToHome', 'HasTarget', 'IsNearTarget', 'IsLowAltitude', ...
    'IsHighAltitude', 'RecentActions', 'MissionComplete'};

for i = 1:numel(scenario.Targets)
    context = getBehaviorContext(scenario.Targets(i), scenario, config);
    for f = 1:numel(requiredFields)
        assert(isfield(context, requiredFields{f}), ...
            'Context missing field: %s.', requiredFields{f});
    end
    assert(isequal(size(context.Position), [3, 1]), 'Context Position must be 3x1.');
end

disp('testBehaviorContext passed.');
