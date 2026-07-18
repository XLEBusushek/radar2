% testBirdInitialization - Проверяет размещение птиц на деревьях (ТЗ-03).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
trees = scenario.Trees;
birds = scenario.Birds;

perchRange = config.birds.perchTimeRange;
hiddenRange = config.birds.hiddenTimeRange;
takeoffRange = config.birds.takeoffTimeRange;

treeIds = [trees.ID];

for i = 1:numel(birds)
    bird = birds(i);
    payload = bird.Payload;

    assert(isfield(payload, 'CurrentTreeID'), ...
        'Bird must have Payload.CurrentTreeID.');

    treeId = payload.CurrentTreeID;
    assert(ismember(treeId, treeIds), ...
        'CurrentTreeID must reference an existing tree.');

    treeIdx = find([trees.ID] == treeId, 1);
    tree = trees(treeIdx);

    distXY = norm(bird.Position(1:2) - tree.Position(1:2));
    assert(distXY <= tree.CrownRadius * 1.5, ...
        'Bird must be near the crown of its tree horizontally.');

    z = bird.Position(3);
    zMin = max(0, tree.Height - tree.CrownRadius * 1.5);
    zMax = tree.Height + tree.CrownRadius * 1.5;
    assert(z >= zMin && z <= zMax, ...
        'Bird height must be near the tree crown.');

    assert(isempty(payload.TargetTreeID), 'TargetTreeID must be empty.');

    assert(payload.PerchDuration >= perchRange(1) && ...
        payload.PerchDuration <= perchRange(2), ...
        'PerchDuration must be within perchTimeRange.');
    assert(payload.HiddenDuration >= hiddenRange(1) && ...
        payload.HiddenDuration <= hiddenRange(2), ...
        'HiddenDuration must be within hiddenTimeRange.');
    assert(payload.TakeoffDuration >= takeoffRange(1) && ...
        payload.TakeoffDuration <= takeoffRange(2), ...
        'TakeoffDuration must be within takeoffTimeRange.');
end

disp('testBirdInitialization passed.');
