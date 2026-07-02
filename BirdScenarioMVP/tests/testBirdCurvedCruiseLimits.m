% testBirdCurvedCruiseLimits - Checks motion limits during curved cruise (ТЗ-05C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 60;
config.sim.dt = 1;
config.birds.fsm.enabled = true;
config.birds.curvedCruise.enabled = true;

[scenario, ~] = runSimulation(config);

maxSpeed = config.birds.motion.speedRange(2);
maxVz = config.birds.motion.maxVerticalSpeed;
maxAccel = config.birds.motion.maxAcceleration;
minAlt = config.birds.curvedCruise.minCruiseAltitude;
maxAlt = config.birds.curvedCruise.maxCruiseAltitude;
worldSize = config.world.size;
tolerance = 1e-6;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;

    speeds = vecnorm(history.Velocity, 2, 2);
    assert(all(speeds <= maxSpeed + tolerance), 'Speed exceeds maximum.');
    assert(all(abs(history.Velocity(:, 3)) <= maxVz + tolerance), ...
        'Vertical speed exceeds maximum.');

    accels = vecnorm(history.Acceleration, 2, 2);
    assert(all(accels <= maxAccel + tolerance + 1e-3), ...
        'Acceleration exceeds maximum.');

    assert(all(~isnan(history.Position(:))), 'Position must not contain NaN.');
    assert(all(~isinf(history.Position(:))), 'Position must not contain Inf.');
    assert(all(~isnan(history.Velocity(:))), 'Velocity must not contain NaN.');
    assert(all(~isinf(history.Velocity(:))), 'Velocity must not contain Inf.');

    assert(all(history.Position(:, 1) >= 0 & history.Position(:, 1) <= worldSize(1)), ...
        'X must stay inside world.');
    assert(all(history.Position(:, 2) >= 0 & history.Position(:, 2) <= worldSize(2)), ...
        'Y must stay inside world.');
    assert(all(history.Position(:, 3) >= 0 & history.Position(:, 3) <= worldSize(3)), ...
        'Z must stay inside world.');

    cruiseIdx = find(string(history.State(:)) == "Cruise");
    if ~isempty(cruiseIdx)
        cruiseZ = history.Position(cruiseIdx, 3);
        assert(all(cruiseZ >= minAlt - tolerance & cruiseZ <= maxAlt + tolerance), ...
            'Cruise altitude must stay within curved cruise bounds.');
    end
end

disp('testBirdCurvedCruiseLimits passed.');
