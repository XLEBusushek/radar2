% testBirdNoLocalCircling - Checks birds leave start area without local loops (ТЗ-06C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 180;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

config.birds.realism.flyByProbability = 0.0;
config.birds.realism.circleBeforeLandingProbability = 0.0;
config.birds.realism.noProgressTimeLimit = 8;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 3;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 3;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 10;
config.birds.fsm.cruise.maxTime = 120;
config.birds.fsm.cruise.landingProbability = 0.0;

[scenario, ~] = runSimulation(config);

minDistance = config.birds.realism.minTargetTreeDistance;
localRadius = 90;
localTimeLimit = 30;
birdsAwayCount = 0;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;
    positions = history.Position;
    times = history.Time(:);
    states = string(history.State(:));

    startTreePos = positions(1, 1:2);

    maxDistFromStart = max(vecnorm(positions(:, 1:2) - startTreePos, 2, 2));
    if maxDistFromStart >= minDistance
        birdsAwayCount = birdsAwayCount + 1;
    end

    firstTakeoffIdx = find(states == "Takeoff", 1, 'first');
    firstLandingIdx = find(states == "Landing", 1, 'first');
    if isempty(firstTakeoffIdx)
        continue;
    end
    if isempty(firstLandingIdx)
        firstLandingIdx = numel(states);
    end

    localTime = 0;
    for k = (firstTakeoffIdx + 1):firstLandingIdx
        if states(k) ~= "Cruise"
            continue;
        end
        dist = norm(positions(k, 1:2) - startTreePos);
        if dist <= localRadius
            localTime = localTime + (times(k) - times(k - 1));
        end
    end
    if maxDistFromStart < minDistance * 0.6
        assert(localTime <= localTimeLimit, ...
            'Bird %d must not remain in a local loop near the start tree.', target.ID);
    end
end

assert(birdsAwayCount >= ceil(0.6 * numel(scenario.Targets)), ...
    'Most birds must travel farther than minTargetTreeDistance from the start tree.');

disp('testBirdNoLocalCircling passed.');
