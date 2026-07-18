function seed = generateScenarioSeed()
% generateScenarioSeed - Генерация сценарного seed на основе времени.
t = datetime("now", "TimeZone", "local");
seed = mod(round(posixtime(t) * 1000), 2^31 - 1);
seed = double(seed);

if seed == 0
    seed = 1;
end
end
