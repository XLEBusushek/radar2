function targets = createTargets(config, scenario)
% createTargets - Создаёт все цели для сценария.
arguments
    config (1, 1) struct
    scenario (1, 1) struct
end

if ~isfield(scenario, 'Trees')
    error('createTargets:MissingField', 'scenario.Trees is required.');
end

trees = scenario.Trees;
targets = struct([]);
nextId = 1;

for i = 1:getConfiguredCount(config, 'birds')
    id = nextId;
    target = createSeededTarget(@() createBirdTarget(id, config, trees), ...
        scenario, id, "bird", "bird");
    targets = appendTarget(targets, target);
    nextId = nextId + 1;
end

if isfield(config, 'quadcopter') && isfield(config.quadcopter, 'count') && ...
        config.quadcopter.count > 0
    for i = 1:config.quadcopter.count
        id = nextId;
        target = createSeededTarget(@() createQuadcopterTarget(id, config), ...
            scenario, id, "air", "quadcopter");
        targets = appendTarget(targets, target);
        nextId = nextId + 1;
    end
end

if isfield(config, 'fixedWing2') && isfield(config.fixedWing2, 'enabled') && ...
        config.fixedWing2.enabled && config.fixedWing2.count > 0
    for i = 1:config.fixedWing2.count
        id = nextId;
        target = createSeededTarget(@() fw2_createFixedWingTarget(id, config), ...
            scenario, id, "air", "fixedWingUAV");
        targets = appendTarget(targets, target);
        nextId = nextId + 1;
    end
elseif isfield(config, 'fixedWing') && isfield(config.fixedWing, 'count') && ...
        config.fixedWing.count > 0
    for i = 1:config.fixedWing.count
        id = nextId;
        target = createSeededTarget(@() createFixedWingTarget(id, config), ...
            scenario, id, "air", "fixedWingUAV");
        targets = appendTarget(targets, target);
        nextId = nextId + 1;
    end
end

if isfield(config, 'groundVehicle') && isfield(config.groundVehicle, 'count') && ...
        config.groundVehicle.count > 0
    if ~isfield(scenario, 'RoadNetwork') || isempty(scenario.RoadNetwork.Roads)
        error('createTargets:MissingRoadNetwork', ...
            'scenario.RoadNetwork is required for ground vehicles.');
    end
    for i = 1:config.groundVehicle.count
        id = nextId;
        target = createSeededTarget(@() createGroundVehicleTarget(id, config, scenario.RoadNetwork), ...
            scenario, id, "ground", "vehicle");
        targets = appendTarget(targets, target);
        nextId = nextId + 1;
    end
end
end

function count = getConfiguredCount(config, sectionName)
count = 0;
if isfield(config, sectionName) && isfield(config.(sectionName), 'count')
    count = config.(sectionName).count;
end
end

function target = createSeededTarget(producer, scenario, targetID, className, subtype)
randomState = scenario.Random;
usePerTargetSeeds = true;
if isfield(randomState, 'UsePerTargetSeeds')
    usePerTargetSeeds = randomState.UsePerTargetSeeds;
end

if usePerTargetSeeds
    targetSeed = createTargetSeed(randomState.ScenarioSeed, targetID, ...
        className, subtype);
    target = runWithTemporaryRNG(targetSeed, producer);
else
    targetSeed = randomState.ScenarioSeed;
    target = producer();
end

target.Metadata.RandomSeed = targetSeed;
target.Metadata.RandomMode = randomState.Mode;
end

function targets = appendTarget(targets, target)
if isempty(targets)
    targets = target;
else
    targets(end + 1) = target;
end
end
