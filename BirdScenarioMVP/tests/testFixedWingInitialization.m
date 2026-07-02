% testFixedWingInitialization - Checks fixed-wing UAV creation (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 3;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
fixedWing = getScenarioFixedWingUAVs(scenario);
rcsRange = config.fixedWing.rcsRange;

assert(numel(fixedWing) == config.fixedWing.count, 'Fixed-wing count mismatch.');
for i = 1:numel(fixedWing)
    uav = fixedWing(i);
    assert(uav.Class == "air", 'Class must be air.');
    assert(uav.Subtype == "fixedWingUAV", 'Subtype must be fixedWingUAV.');
    assert(uav.Position(3) >= 80, 'Fixed-wing UAV must start airborne.');
    assert(norm(uav.Velocity) >= config.fixedWing.minSpeed, 'Initial speed must be nonzero.');
    assert(uav.RCS >= rcsRange(1) && uav.RCS <= rcsRange(2), 'RCS out of range.');
    validateTarget(uav, config);
end

disp('testFixedWingInitialization passed.');
