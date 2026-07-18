% testBirdCruiseMotion - Проверяет кинематику крейсера к целевому дереву (ТЗ-05B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 40;
config.sim.dt = 1;
config.birds.fsm.enabled = true;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 1;
config.birds.fsm.cruise.maxTime = 30;
config.birds.fsm.cruise.landingProbability = 0.0;

[scenario, ~] = runSimulation(config);

maxSpeed = config.birds.motion.speedRange(2);
tolerance = 1e-6;
foundCruiseBird = false;
foundApproach = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));
    cruiseIdx = find(states == "Cruise");

    if isempty(cruiseIdx)
        continue;
    end

    foundCruiseBird = true;
    positions = target.History.Position(cruiseIdx, :);
    velocities = target.History.Velocity(cruiseIdx, :);

    assert(any(vecnorm(velocities, 2, 2) > 0), ...
        'Bird speed must be positive during Cruise.');
    assert(any(vecnorm(diff(positions, 1, 1), 2, 2) > 0), ...
        'Bird position must change during Cruise.');
    assert(all(vecnorm(velocities, 2, 2) <= maxSpeed + tolerance), ...
        'Cruise speed must not exceed maximum.');

    if isfield(target.History, 'DistanceToTargetTree') && numel(cruiseIdx) > 1
        distances = target.History.DistanceToTargetTree(cruiseIdx);
        distances = distances(~isnan(distances));
        if numel(distances) > 1
            if distances(end) < distances(1)
                foundApproach = true;
            end
        end
    end
end

assert(foundCruiseBird, 'At least one bird must enter Cruise.');
assert(foundApproach, ...
    'At least one bird must reduce distance to target tree during Cruise.');

disp('testBirdCruiseMotion passed.');
