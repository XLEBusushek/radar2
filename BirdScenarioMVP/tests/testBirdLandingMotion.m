% testBirdLandingMotion - Проверяет плавное движение при посадке (ТЗ-05D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 180;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.birds.landing.enabled = true;
config.birds.landing.approachRadius = 120;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 10;
config.birds.fsm.cruise.maxTime = 40;
config.birds.fsm.cruise.landingProbability = 1.0;
config.birds.fsm.cruise.landingProbability = 0.0;
config.birds.fsm.landing.minTime = 2;
config.birds.fsm.landing.maxTime = 25;
config.birds.fsm.landing.hiddenProbability = 1.0;

[scenario, ~] = runSimulation(config);

maxLandingSpeed = config.birds.landing.speedRange(2);
maxLandingVz = config.birds.landing.maxVerticalSpeed;
tolerance = 1e-6;
foundLandingBird = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));
    landingIdx = find(states == "Landing");

    if isempty(landingIdx)
        continue;
    end

    foundLandingBird = true;
    positions = target.History.Position(landingIdx, :);
    velocities = target.History.Velocity(landingIdx, :);

    assert(any(vecnorm(diff(positions, 1, 1), 2, 2) > 0), ...
        'Bird position must change during Landing.');

    if isfield(target.History, 'LandingDistance') && numel(landingIdx) > 1
        distances = target.History.LandingDistance(landingIdx);
        distances = distances(~isnan(distances));
        if numel(distances) > 1
            approached = min(distances) < distances(1) - 0.5 || ...
                distances(end) <= config.birds.landing.touchdownDistance + 3;
            assert(approached, ...
                'Landing must approach the target point.');
        end
    end

    speeds = vecnorm(velocities, 2, 2);
    assert(all(speeds <= maxLandingSpeed + tolerance), ...
        'Landing speed must not exceed maximum.');
    assert(all(abs(velocities(:, 3)) <= maxLandingVz + tolerance), ...
        'Landing vertical speed must stay within limits.');

    assert(all(~isnan(positions(:))), 'Landing positions must not contain NaN.');
    assert(all(~isinf(positions(:))), 'Landing positions must not contain Inf.');
end

assert(foundLandingBird, 'At least one bird must enter Landing.');

disp('testBirdLandingMotion passed.');
