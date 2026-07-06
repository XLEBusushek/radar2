function scenario = initializeScenario(config, randomState)
% initializeScenario - Create initial scenario state.
arguments
    config (1, 1) struct
    randomState (1, 1) struct = struct()
end

if isempty(fieldnames(randomState))
    randomState = initializeRandomSystem(config);
end

scenario.Config = config;
scenario.Time = 0;
scenario.Random = randomState;
scenario.Trees = generateTrees(config);
if shouldGenerateRoadNetwork(config)
    scenario.RoadNetwork = generateRoadNetwork(config);
else
    scenario.RoadNetwork = emptyRoadNetwork();
end
scenario.Targets = createTargets(config, scenario);
scenario.Random.SeedLog = buildRandomSeedLog(scenario.Targets);
scenario.TargetIndices = splitTargetsByType(scenario.Targets);
scenario = syncScenarioTargetViews(scenario);
scenario.Metadata.CreatedBy = "initializeScenario";
scenario.Metadata.RandomMode = randomState.Mode;
scenario.Metadata.ScenarioSeed = randomState.ScenarioSeed;
scenario.Metadata.RandomCreatedAt = randomState.CreatedAt;
end

function tf = shouldGenerateRoadNetwork(config)
tf = false;
if isfield(config, 'groundVehicle') && isfield(config.groundVehicle, 'count') && ...
        config.groundVehicle.count > 0
    tf = true;
    return;
end
if isfield(config, 'visualization') && isfield(config.visualization, 'showRoads') && ...
        config.visualization.showRoads
    tf = true;
end
end

function roadNetwork = emptyRoadNetwork()
roadNetwork.Roads = struct([]);
roadNetwork.Intersections = struct([]);
roadNetwork.Metadata.CreatedBy = "initializeScenario";
roadNetwork.Metadata.RoadCount = 0;
roadNetwork.Metadata.IntersectionCount = 0;
end

function seedLog = buildRandomSeedLog(targets)
seedLog = struct('TargetID', {}, 'Class', {}, 'Subtype', {}, 'Seed', {});
for i = 1:numel(targets)
    seedLog(i).TargetID = targets(i).ID; %#ok<AGROW>
    seedLog(i).Class = string(targets(i).Class);
    seedLog(i).Subtype = string(targets(i).Subtype);
    if isfield(targets(i), 'Metadata') && isfield(targets(i).Metadata, 'RandomSeed')
        seedLog(i).Seed = targets(i).Metadata.RandomSeed;
    else
        seedLog(i).Seed = nan;
    end
end
end
