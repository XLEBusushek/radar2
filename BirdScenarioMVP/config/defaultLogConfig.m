function config = defaultLogConfig(config)
% defaultLogConfig - Значения по умолчанию для записи TrajectoryLog.
%
% historyMode:
%   "full"    - полная target.History на каждом шаге (по умолчанию для тестов)
%   "minimal" - базовые поля + поля, необходимые для анализа/тестов
%   "off"     - только базовая кинематика (Time, Position, Velocity, State, ...)
%   "none"    - без добавления History на каждом шаге (бенчмарк / максимальная скорость)
config.log.legacyPerFrame = false;
config.log.storePayload = true;
config.log.storeFullPayload = true;
config.log.preallocateFrames = true;
config.log.historyMode = "full";
config.log.buildLegacyOutput = true;
config.log.incrementalCsv = false;
end
