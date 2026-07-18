function config = defaultRoadConfig(config)
% defaultRoadConfig - Значения по умолчанию для генерации дорожной сети.
config.roads.enabled = true;
config.roads.countRange = [5, 15];
config.roads.lengthRange = [100, 1200];
config.roads.widthRange = [4, 14];
config.roads.speedLimitRange = [8, 30];
config.roads.margin = 50;
config.roads.intersectionTolerance = 5;
config.roads.mainRoadCountRange = [2, 4];
config.roads.mainRoadLengthRange = [1200, 2600];
config.roads.mainRoadWidthRange = [8, 14];
config.roads.mainRoadSpeedLimitRange = [15, 30];
config.roads.secondaryRoadCountRange = [4, 10];
config.roads.secondaryRoadLengthRange = [500, 1400];
config.roads.secondaryRoadWidthRange = [4, 8];
config.roads.secondaryRoadSpeedLimitRange = [8, 18];
config.roads.maxGenerationAttempts = 20;
config.roads.minTotalLength = 4000;
config.roads.minConnectedFraction = 0.90;
config.roads.minRoadLength = 250;
config.roads.minNodeCount = 5;
end
