% testFixedWingNoBoundaryBounce - Checks smooth turns near world boundaries (ТЗ-09G).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 77;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.sim.duration = 120;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

worldSize = config.world.size;
speed = mean(config.fixedWing.cruiseSpeedRange);
starts = {
    [1400; 1000; 200], [speed; 0; 0]
    [600; 1000; 200], [-speed; 0; 0]
    [1000; 1400; 200], [0; speed; 0]
    [1000; 600; 200], [0; -speed; 0]
};
simSteps = 50;

for wallIdx = 1:size(starts, 1)
    setScenarioRNG(config.sim.random.seed + wallIdx);
    scenario = initializeScenario(config);
    uav = getScenarioFixedWingUAVs(scenario);
    uav = uav(1);
    uav.Position = starts{wallIdx, 1};
    uav.Velocity = starts{wallIdx, 2};
    uav.Payload.CurrentHeading = atan2(uav.Velocity(2), uav.Velocity(1));
    uav.Payload.SmoothedHeading = uav.Payload.CurrentHeading;
    uav = appendTargetHistory(uav);

    for k = 1:simSteps
        uav = updateTarget(uav, scenario, config, config.sim.dt);
        assert(all(uav.Position(1:2) >= 0) && uav.Position(1) <= worldSize(1) && ...
            uav.Position(2) <= worldSize(2), ...
            'UAV left world bounds on wall %d at step %d.', wallIdx, k);
    end

    nearBoundary = logical(uav.History.NearBoundary(:));
    headings = uav.History.CurrentHeading(:);
    reversalWindow = 3;
    maxReversalDeg = 60;
    for k = 1:(numel(headings) - reversalWindow)
        if ~any(nearBoundary(k:(k + reversalWindow)))
            continue;
        end
        delta = abs(wrapToPiLocal(headings(k + reversalWindow) - headings(k))) * 180 / pi;
        assert(delta <= maxReversalDeg + 5, ...
            'Sharp heading reversal near boundary on wall %d.', wallIdx);
    end

    positions = uav.History.Position(:, 1:2);
    nearMask = logical(uav.History.NearBoundary(:));
    minRadius = computeMinTurnRadiusXY(positions, worldSize, nearMask);
    assert(minRadius >= 150, ...
        'Turn radius too small near boundary on wall %d (%.1f m).', wallIdx, minRadius);
end

disp('testFixedWingNoBoundaryBounce passed.');

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end

function minRadius = computeMinTurnRadiusXY(positions, worldSize, nearMask)
minRadius = inf;
n = size(positions, 1);
edgeTol = 15;
step = 4;
for i = (step + 1):(n - step)
    if nargin >= 3 && ~isempty(nearMask) && ~nearMask(i)
        continue;
    end
    p2 = positions(i, :);
    if p2(1) <= edgeTol || p2(2) <= edgeTol || ...
            p2(1) >= worldSize(1) - edgeTol || p2(2) >= worldSize(2) - edgeTol
        continue;
    end
    p1 = positions(i - step, :);
    p3 = positions(i + step, :);
    a = norm(p2 - p1);
    b = norm(p3 - p2);
    c = norm(p3 - p1);
    if a < 15 || b < 15
        continue;
    end
    s = (a + b + c) / 2;
    areaSq = s * (s - a) * (s - b) * (s - c);
    if areaSq <= 1
        continue;
    end
    radius = a * b * c / (4 * sqrt(areaSq));
    minRadius = min(minRadius, radius);
end
if isinf(minRadius)
    minRadius = inf;
end
end
