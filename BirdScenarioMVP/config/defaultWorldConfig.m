function config = defaultWorldConfig(config)
% defaultWorldConfig - World, simulation, environment, and debug defaults.
config.world.size = [2000, 2000, 500];

config.sim.dt = 1.0;
config.sim.duration = 300;
config.sim.seed = 42;
config.sim.random.mode = "randomized";
config.sim.random.seed = config.sim.seed;
config.sim.random.usePerTargetSeeds = true;
config.sim.random.saveSeed = true;
config.sim.random.saveSeedToOutput = true;
config.sim.random.shuffleMethod = "clock";

config.targets.enableUniversalTargetModel = true;

config.environment.numTrees = 80;
config.environment.treeHeightRange = [8, 30];
config.environment.crownRadiusRange = [2, 8];
config.environment.treeMargin = 20;

config.debug.verbose = true;
config.debug.validateEachStep = true;
end
