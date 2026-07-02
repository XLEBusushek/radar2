function setScenarioRNG(seed)
% setScenarioRNG - Set MATLAB global RNG with validation.
arguments
    seed (1, 1) double
end

if isempty(seed) || isnan(seed) || isinf(seed)
    error('setScenarioRNG:InvalidSeed', 'Seed must be a finite scalar.');
end
if seed ~= floor(seed)
    error('setScenarioRNG:InvalidSeed', 'Seed must be an integer.');
end
if seed < 0 || seed > 2^32 - 1
    error('setScenarioRNG:InvalidSeed', 'Seed must be in MATLAB rng range.');
end

rng(seed);
end
