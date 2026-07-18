function config = defaultBehaviorConfig(config)
% defaultBehaviorConfig - Значения по умолчанию для системы поведения.
config.behavior.enabled = true;
config.behavior.decisionPeriodRange = [0.5, 3.0];
config.behavior.recentActionMemoryLength = 10;
config.behavior.cooldownDefault = 5.0;
config.behavior.logDecisionWeights = true;
end
