function randomState = initializeRandomSystem(config)
% initializeRandomSystem - Initialize global RNG and return scenario random state.
arguments
    config (1, 1) struct
end

randomConfig = getRandomConfig(config);
mode = string(randomConfig.mode);

switch mode
    case "deterministic"
        scenarioSeed = getDeterministicSeed(config, randomConfig);
    case "randomized"
        scenarioSeed = generateScenarioSeed();
    otherwise
        error('initializeRandomSystem:InvalidMode', ...
            'Unsupported random mode: %s.', mode);
end

setScenarioRNG(scenarioSeed);

randomState.Mode = mode;
randomState.ScenarioSeed = scenarioSeed;
randomState.CreatedAt = string(datetime("now", "Format", "yyyy-MM-dd HH:mm:ss.SSS"));
randomState.UsePerTargetSeeds = logical(randomConfig.usePerTargetSeeds);
randomState.SeedLog = struct('TargetID', {}, 'Class', {}, 'Subtype', {}, 'Seed', {});
end

function randomConfig = getRandomConfig(config)
if isfield(config.sim, 'random')
    randomConfig = config.sim.random;
else
    randomConfig = struct();
end

if ~isfield(randomConfig, 'mode')
    randomConfig.mode = "deterministic";
end
if ~isfield(randomConfig, 'seed')
    randomConfig.seed = config.sim.seed;
end
if ~isfield(randomConfig, 'usePerTargetSeeds')
    randomConfig.usePerTargetSeeds = true;
end
end

function seed = getDeterministicSeed(config, randomConfig)
seed = randomConfig.seed;
if isfield(config.sim, 'seed') && config.sim.seed ~= 42 && randomConfig.seed == 42
    % Backward compatibility for callers that still override config.sim.seed only.
    seed = config.sim.seed;
end
end
