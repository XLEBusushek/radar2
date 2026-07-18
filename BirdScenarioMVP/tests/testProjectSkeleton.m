% testProjectSkeleton - Базовые проверки каркаса проекта (ТЗ-01).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
assert(isequal(config.world.size, [2000, 2000, 500]), ...
    'config.world.size must be [2000 2000 500].');

[scenario, output] = runSimulation(config);
assert(isstruct(scenario), 'scenario must be a struct.');
assert(isstruct(output), 'output must be a struct.');

stateMatrix = computeStateMatrix([1; 2; 3], [4; 5; 6]);
assert(isequal(stateMatrix, [1, 4; 2, 5; 3, 6]), ...
    'computeStateMatrix failed for column vectors.');

stateMatrixRow = computeStateMatrix([1, 2, 3], [4, 5, 6]);
assert(isequal(stateMatrixRow, [1, 4; 2, 5; 3, 6]), ...
    'computeStateMatrix failed for row vectors.');

vLimited = limitVectorNorm([3; 4], 10);
assert(isequal(vLimited, [3; 4]), 'limitVectorNorm should not change vector below max.');

vLimited = limitVectorNorm([3; 4], 2.5);
expected = [3; 4] * (2.5 / 5);
assert(norm(vLimited - expected) < 1e-12, 'limitVectorNorm should clamp to maxNorm.');

vLimited = limitVectorNorm([0; 0], 5);
assert(isequal(vLimited, [0; 0]), 'limitVectorNorm should leave zero vector unchanged.');

position = enforceWorldBounds([-10; 2500; 300], config.world.size);
assert(isequal(position, [0; 2000; 300]), 'enforceWorldBounds failed for out-of-range values.');

position = enforceWorldBounds([100; 200; 50], config.world.size);
assert(isequal(position, [100; 200; 50]), 'enforceWorldBounds should not change in-range values.');

disp('testProjectSkeleton passed.');
