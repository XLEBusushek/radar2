% testBirdCurvedCruiseMotion - Проверяет нелинейные траектории крейсера (ТЗ-05C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 80;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.birds.curvedCruise.enabled = true;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 20;
config.birds.fsm.cruise.maxTime = 60;
config.birds.fsm.cruise.landingProbability = 0.0;

[scenario, ~] = runSimulation(config);

foundCurvedBird = false;
minDeviationThreshold = 2.0;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));
    cruiseIdx = find(states == "Cruise");

    if numel(cruiseIdx) < 3
        continue;
    end

    positions = target.History.Position(cruiseIdx, :);
    assert(any(vecnorm(diff(positions, 1, 1), 2, 2) > 0), ...
        'Bird position must change during Cruise.');

    lineStart = positions(1, 1:2);
    lineEnd = positions(end, 1:2);
    maxDev = maxPointToLineDistance2D(positions(:, 1:2), lineStart, lineEnd);

    if maxDev > minDeviationThreshold
        foundCurvedBird = true;
    end
end

assert(foundCurvedBird, ...
    'At least one bird must have a non-straight cruise trajectory.');

disp('testBirdCurvedCruiseMotion passed.');

function maxDist = maxPointToLineDistance2D(points, lineStart, lineEnd)
lineVec = lineEnd - lineStart;
lineLen = norm(lineVec);

if lineLen < 1e-9
    maxDist = max(vecnorm(points - lineStart, 2, 2));
    return;
end

lineUnit = lineVec / lineLen;
distances = zeros(size(points, 1), 1);
for k = 1:size(points, 1)
    w = points(k, :) - lineStart;
    projLen = dot(w, lineUnit);
    proj = projLen * lineUnit;
    perp = w - proj;
    distances(k) = norm(perp);
end
maxDist = max(distances);
end
