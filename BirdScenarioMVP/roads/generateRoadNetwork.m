function roadNetwork = generateRoadNetwork(config)
% generateRoadNetwork - Создание случайной процедурной дорожной сети.
arguments
    config (1, 1) struct
end

if ~isfield(config, 'roads') || ~isfield(config.roads, 'enabled') || ~config.roads.enabled
    roadNetwork = emptyRoadNetwork();
    return;
end

maxAttempts = config.roads.maxGenerationAttempts;
bestNetwork = emptyRoadNetwork();
bestScore = -inf;
for attempt = 1:maxAttempts
    mainRoads = generateMainRoads(config);
    secondaryRoads = generateSecondaryRoads(mainRoads, config);
    roads = connectRoads([mainRoads, secondaryRoads], config);
    candidate = buildRoadGraph(roads, config);
    candidate.Metadata.GenerationAttempt = attempt;
    [isValid, report] = validateRoadNetwork(candidate, config);
    candidate.Metadata.ValidationReport = report;
    score = report.ConnectedFraction + 0.0001 * report.TotalLength + 0.01 * report.NodeCount;
    if score > bestScore
        bestScore = score;
        bestNetwork = candidate;
    end
    if isValid
        roadNetwork = candidate;
        roadNetwork.Metadata.CreatedBy = "generateRoadNetwork";
        return;
    end
end

roadNetwork = bestNetwork;
roadNetwork.Metadata.CreatedBy = "generateRoadNetwork";
end

function roadNetwork = emptyRoadNetwork()
roadNetwork.Nodes = struct([]);
roadNetwork.Edges = struct([]);
roadNetwork.Adjacency = {};
roadNetwork.MainRoadIDs = [];
roadNetwork.SecondaryRoadIDs = [];
roadNetwork.Bounds = [];
roadNetwork.Roads = struct([]);
roadNetwork.Paths = struct([]);
roadNetwork.Intersections = struct([]);
roadNetwork.Metadata.CreatedBy = "generateRoadNetwork";
roadNetwork.Metadata.RoadCount = 0;
roadNetwork.Metadata.EdgeCount = 0;
roadNetwork.Metadata.NodeCount = 0;
roadNetwork.Metadata.IntersectionCount = 0;
end
