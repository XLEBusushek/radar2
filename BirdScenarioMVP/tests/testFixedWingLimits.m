% testFixedWingLimits - Checks fixed-wing kinematic limits (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 2;
config.sim.duration = 80;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
fixedWing = getScenarioFixedWingUAVs(scenario);
fw = config.fixedWing;

for i = 1:numel(fixedWing)
    pos = fixedWing(i).History.Position;
    vel = fixedWing(i).History.Velocity;
    acc = fixedWing(i).History.Acceleration;
    speeds = vecnorm(vel, 2, 2);
    accNorm = vecnorm(acc, 2, 2);

    assert(all(all(isfinite(pos))) && all(all(isfinite(vel))) && all(all(isfinite(acc))), ...
        'History must not contain NaN/Inf.');
    assert(all(speeds >= fw.minSpeed - 0.5), 'Speed below minSpeed.');
    assert(all(speeds <= fw.maxSpeed + 0.5), 'Speed exceeds maxSpeed.');
    assert(all(abs(vel(:, 3)) <= fw.maxVerticalSpeed + 0.5), 'Vertical speed exceeds limit.');
    assert(all(accNorm <= fw.maxAcceleration + 1.0), 'Acceleration exceeds limit.');
    assert(all(pos(:, 3) >= fw.operatingAltitudeRange(1) - 5), 'Altitude below operating range.');
    assert(all(pos(:, 3) <= fw.operatingAltitudeRange(2) + 1), 'Altitude above operating range.');
end

disp('testFixedWingLimits passed.');
