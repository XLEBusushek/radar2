% testTargets - Checks for universal target model (ТЗ-03).
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
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);

assert(isfield(scenario, 'Targets'), 'scenario must have Targets field.');
assert(numel(scenario.Targets) == config.birds.count, ...
    'Target count must match config.birds.count.');

worldSize = config.world.size;
rcsRange = config.birds.rcsRange;
ids = [];

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);

    assert(target.Class == "bird", 'Class must be "bird".');
    assert(target.Subtype == "bird", 'Subtype must be "bird".');
    assert(~ismember(target.ID, ids), 'Target IDs must be unique.');
    ids(end + 1) = target.ID; %#ok<AGROW>

    assert(isequal(size(target.Position), [3, 1]), 'Position must be 3x1.');
    assert(isequal(size(target.Velocity), [3, 1]), 'Velocity must be 3x1.');
    assert(isequal(size(target.Acceleration), [3, 1]), 'Acceleration must be 3x1.');
    assert(isequal(target.Velocity, [0; 0; 0]), 'Velocity must be zero.');
    assert(isequal(target.Acceleration, [0; 0; 0]), 'Acceleration must be zero.');

    assert(target.State == "Perched", 'State must be Perched.');
    assert(target.Mission == "TreeToTree", 'Mission must be TreeToTree.');
    assert(target.Visible == false, 'Visible must be false.');

    assert(target.RCS >= rcsRange(1) && target.RCS <= rcsRange(2), ...
        'RCS must be within rcsRange.');
    assert(isequal(size(target.StateMatrix), [3, 2]), 'StateMatrix must be 3x2.');

    assert(isfield(target, 'Payload'), 'Target must have Payload.');
    assert(isfield(target, 'History'), 'Target must have History.');

    assert(target.Position(1) >= 0 && target.Position(1) <= worldSize(1), ...
        'Position X must be inside world.');
    assert(target.Position(2) >= 0 && target.Position(2) <= worldSize(2), ...
        'Position Y must be inside world.');
    assert(target.Position(3) >= 0 && target.Position(3) <= worldSize(3), ...
        'Position Z must be inside world.');

    assert(all(~isnan([target.Position; target.Velocity; target.Acceleration])), ...
        'Target vectors must not contain NaN.');
    assert(all(~isinf([target.Position; target.Velocity; target.Acceleration])), ...
        'Target vectors must not contain Inf.');
    assert(~isnan(target.RCS) && ~isinf(target.RCS), 'RCS must be finite.');

    validateTarget(target, config);
end

disp('testTargets passed.');
