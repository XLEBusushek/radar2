% testBirdMotionLimits - Checks motion limits over full history (ТЗ-05B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 30;
config.sim.dt = 1;
config.birds.fsm.enabled = true;

[scenario, ~] = runSimulation(config);

maxSpeed = config.birds.motion.speedRange(2);
maxVz = config.birds.motion.maxVerticalSpeed;
worldSize = config.world.size;
tolerance = 1e-6;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;

    speeds = vecnorm(history.Velocity, 2, 2);
    assert(all(speeds <= maxSpeed + tolerance), ...
        'Speed must not exceed configured maximum.');
    assert(all(abs(history.Velocity(:, 3)) <= maxVz + tolerance), ...
        'Vertical speed must stay within limits.');

    assert(all(~isnan(history.Position(:))), 'Position must not contain NaN.');
    assert(all(~isinf(history.Position(:))), 'Position must not contain Inf.');
    assert(all(~isnan(history.Velocity(:))), 'Velocity must not contain NaN.');
    assert(all(~isinf(history.Velocity(:))), 'Velocity must not contain Inf.');
    assert(all(~isnan(history.Acceleration(:))), 'Acceleration must not contain NaN.');
    assert(all(~isinf(history.Acceleration(:))), 'Acceleration must not contain Inf.');

    assert(all(history.Position(:, 1) >= 0 & history.Position(:, 1) <= worldSize(1)), ...
        'X must stay inside world.');
    assert(all(history.Position(:, 2) >= 0 & history.Position(:, 2) <= worldSize(2)), ...
        'Y must stay inside world.');
    assert(all(history.Position(:, 3) >= 0 & history.Position(:, 3) <= worldSize(3)), ...
        'Z must stay inside world.');
end

disp('testBirdMotionLimits passed.');
