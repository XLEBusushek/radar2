% testQuadcopterInitialization - Проверяет создание квадрокоптера (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 5;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
quadcopters = getScenarioQuadcopters(scenario);

assert(numel(quadcopters) == config.quadcopter.count, ...
    'Quadcopter count must match config.quadcopter.count.');

rcsRange = config.quadcopter.rcsRange;
for i = 1:numel(quadcopters)
    qc = quadcopters(i);
    assert(qc.Class == "air", 'Class must be air.');
    assert(qc.Subtype == "quadcopter", 'Subtype must be quadcopter.');
    assert(qc.Position(3) == 0, 'Quadcopter must start on ground.');
    assert(qc.State == "Idle", 'Initial state must be Idle.');
    assert(qc.RCS >= rcsRange(1) && qc.RCS <= rcsRange(2), 'RCS out of range.');
    validateTarget(qc, config);
end

disp('testQuadcopterInitialization passed.');
