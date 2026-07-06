function config = defaultLogConfig(config)
% defaultLogConfig - TrajectoryLog recording defaults.
config.log.legacyPerFrame = false;
config.log.storePayload = true;
config.log.storeFullPayload = true;
config.log.preallocateFrames = true;
config.log.historyMode = "full";
config.log.buildLegacyOutput = true;
config.log.incrementalCsv = false;
end
