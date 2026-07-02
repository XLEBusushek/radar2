function result = runWithTemporaryRNG(seed, producer)
% runWithTemporaryRNG - Run a producer with a temporary RNG seed.
arguments
    seed (1, 1) double
    producer (1, 1) function_handle
end

previousState = rng;
cleanup = onCleanup(@() rng(previousState));
setScenarioRNG(seed);

result = producer();
end
