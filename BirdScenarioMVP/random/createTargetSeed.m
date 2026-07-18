function targetSeed = createTargetSeed(scenarioSeed, targetID, className, subtype)
% createTargetSeed - Создание стабильного per-target seed из сценарного seed и идентификатора цели.
arguments
    scenarioSeed (1, 1) double
    targetID (1, 1) double
    className (1, 1) string
    subtype (1, 1) string
end

rawSeed = scenarioSeed + targetID * 10007 + ...
    sum(double(char(className))) * 101 + sum(double(char(subtype))) * 17;
targetSeed = mod(round(rawSeed), 2^31 - 1);

if targetSeed == 0
    targetSeed = 1;
end
end
