function config = defaultLogConfig(config)
% defaultLogConfig - TrajectoryLog recording defaults.
%
% historyMode:
%   "full"    - full per-step target.History (tests default)
%   "minimal" - core + fields needed by analysis/tests
%   "off"     - core kinematics only (Time, Position, Velocity, State, ...)
%   "none"    - no per-step History append (benchmark / max speed)
config.log.legacyPerFrame = false;
config.log.storePayload = true;
config.log.storeFullPayload = true;
config.log.preallocateFrames = true;
config.log.historyMode = "full";
config.log.buildLegacyOutput = true;
config.log.incrementalCsv = false;
end
