function config = defaultConfig()
% defaultConfig - Return default project configuration.
config.project.name = "BirdScenarioMVP";
config.project.version = "0.1.0";

config = defaultWorldConfig(config);
config = defaultBirdConfig(config);
config = defaultRoadConfig(config);
config = defaultGroundConfig(config);
config = defaultQuadcopterConfig(config);
config = defaultFixedWingLegacyConfig(config);
config = defaultFixedWing2Config(config);
config = defaultExportConfig(config);
config = defaultAnalysisConfig(config);
config = defaultBehaviorConfig(config);
config = defaultLogConfig(config);
end
