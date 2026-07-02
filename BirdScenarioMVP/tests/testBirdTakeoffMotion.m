% testBirdTakeoffMotion - Checks takeoff kinematics (ТЗ-05B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 25;
config.sim.dt = 1;
config.birds.fsm.enabled = true;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 5;
config.birds.fsm.takeoff.cruiseProbability = 0.5;

[scenario, ~] = runSimulation(config);

maxSpeed = config.birds.motion.speedRange(2);
maxVz = config.birds.motion.maxVerticalSpeed;
tolerance = 1e-6;

foundTakeoffBird = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));
    takeoffIdx = find(states == "Takeoff");

    if isempty(takeoffIdx)
        continue;
    end

    foundTakeoffBird = true;
    positions = target.History.Position(takeoffIdx, :);
    velocities = target.History.Velocity(takeoffIdx, :);
    visible = target.History.Visible(takeoffIdx);

    assert(any(visible), 'Bird must be visible during Takeoff.');
    assert(any(vecnorm(velocities, 2, 2) > 0), ...
        'Bird speed must become positive during Takeoff.');

    firstTakeoffIdx = takeoffIdx(1);
    if firstTakeoffIdx > 1
        posBefore = target.History.Position(firstTakeoffIdx - 1, :);
        assert(any(vecnorm(positions - posBefore, 2, 2) > 0) || ...
            any(vecnorm(diff(positions, 1, 1), 2, 2) > 0), ...
            'Bird position must change during Takeoff.');
        assert(any(positions(:, 3) > posBefore(3)), ...
            'Bird altitude must increase during Takeoff.');
    elseif size(positions, 1) > 1
        assert(any(vecnorm(diff(positions, 1, 1), 2, 2) > 0), ...
            'Bird position must change during Takeoff.');
        assert(any(diff(positions(:, 3)) > 0), ...
            'Bird altitude must increase during Takeoff.');
    end

    speeds = vecnorm(velocities, 2, 2);
    assert(all(speeds <= maxSpeed + tolerance), ...
        'Takeoff speed must not exceed maximum.');
    assert(all(abs(velocities(:, 3)) <= maxVz + tolerance), ...
        'Takeoff vertical speed must stay within limits.');
end

assert(foundTakeoffBird, 'At least one bird must enter Takeoff.');

disp('testBirdTakeoffMotion passed.');
