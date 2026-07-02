% testQuadcopterLimits - Checks kinematic limits over history (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 2;
config.birds.count = 0;
config.sim.duration = 90;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
worldSize = config.world.size;
maxSpeed = config.quadcopter.speedRange(2);
maxVz = config.quadcopter.maxVerticalSpeed;
maxAccel = config.quadcopter.maxAcceleration;

quadcopters = getScenarioQuadcopters(scenario);
for i = 1:numel(quadcopters)
    qc = quadcopters(i);
    pos = qc.History.Position;
    vel = qc.History.Velocity;
    acc = qc.History.Acceleration;

    assert(all(all(isfinite(pos))), 'Position must be finite.');
    assert(all(all(isfinite(vel))), 'Velocity must be finite.');
    assert(all(all(isfinite(acc))), 'Acceleration must be finite.');

    speeds = vecnorm(vel, 2, 2);
    assert(all(speeds <= maxSpeed + 0.5), 'Speed exceeds limit.');
    assert(all(abs(vel(:, 3)) <= maxVz + 0.5), 'Vertical speed exceeds limit.');

    accNorm = vecnorm(acc, 2, 2);
    assert(all(accNorm <= maxAccel + 1.0), 'Acceleration exceeds limit.');

    assert(all(pos(:, 1) >= 0 & pos(:, 1) <= worldSize(1)), 'X out of world.');
    assert(all(pos(:, 2) >= 0 & pos(:, 2) <= worldSize(2)), 'Y out of world.');
    assert(all(pos(:, 3) >= 0 & pos(:, 3) <= worldSize(3)), 'Z out of world.');
end

disp('testQuadcopterLimits passed.');
