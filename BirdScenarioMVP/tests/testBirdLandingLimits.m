% testBirdLandingLimits - Checks landing motion limits (ТЗ-05D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 90;
config.sim.dt = 1;
config.birds.fsm.enabled = true;
config.birds.landing.enabled = true;

[scenario, ~] = runSimulation(config);

maxSpeed = config.birds.motion.speedRange(2);
maxVz = config.birds.motion.maxVerticalSpeed;
maxAccel = config.birds.motion.maxAcceleration;
maxLandingSpeed = config.birds.landing.speedRange(2);
worldSize = config.world.size;
tolerance = 1e-6;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;

    speeds = vecnorm(history.Velocity, 2, 2);
    assert(all(speeds <= maxSpeed + tolerance), 'Speed exceeds global maximum.');
    assert(all(abs(history.Velocity(:, 3)) <= maxVz + tolerance), ...
        'Vertical speed exceeds global maximum.');

    accels = vecnorm(history.Acceleration, 2, 2);
    assert(all(accels <= maxAccel + tolerance + 1e-3), ...
        'Acceleration exceeds maximum.');

    assert(all(~isnan(history.Position(:))), 'Position must not contain NaN.');
    assert(all(~isinf(history.Position(:))), 'Position must not contain Inf.');

    landingIdx = find(string(history.State(:)) == "Landing");
    if ~isempty(landingIdx)
        landingSpeeds = vecnorm(history.Velocity(landingIdx, :), 2, 2);
        assert(all(landingSpeeds <= maxLandingSpeed + tolerance), ...
            'Landing speed exceeds landing maximum.');
    end
end

disp('testBirdLandingLimits passed.');
