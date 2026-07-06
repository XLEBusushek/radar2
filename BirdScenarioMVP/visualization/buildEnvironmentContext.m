function env = buildEnvironmentContext(scenario, config)
% buildEnvironmentContext - Static world data for visualization (not simulation state).
arguments
    scenario (1, 1) struct
    config (1, 1) struct
end

env = struct();
if isfield(scenario, 'Trees')
    env.Trees = scenario.Trees;
else
    env.Trees = struct([]);
end
if isfield(scenario, 'RoadNetwork')
    env.RoadNetwork = scenario.RoadNetwork;
else
    env.RoadNetwork = struct([]);
end
if isfield(config, 'world') && isfield(config.world, 'size')
    env.WorldSize = config.world.size;
else
    env.WorldSize = [2000, 2000, 500];
end
end
