% testFixedWingNoBounce - Checks fixed-wing trajectory has no sharp lateral bounces (ТЗ-09F).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 55;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.sim.duration = 300;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

headings = uav.History.CurrentHeading;
delta = abs(arrayfun(@wrapToPiLocal, diff(headings)));
turnLimit = deg2rad(config.fixedWing.turn.maxTurnRateDeg) * config.sim.dt;
jumpLimit = deg2rad(config.fixedWing.antiBounce.maxHeadingJumpDeg + 2);
maxAllowed = max(turnLimit, jumpLimit) + 0.05;
assert(all(delta <= maxAllowed), 'Heading change exceeds anti-bounce limits.');

positions = uav.History.Position(:, 1:2);
localRadius = 50;
localWindow = 15;
for k = 1:(size(positions, 1) - localWindow)
    segment = positions(k:(k + localWindow), :);
    center = mean(segment, 1);
    if all(vecnorm(segment - center, 2, 2) <= localRadius)
        error('Fixed-wing UAV formed a sharp lateral bounce loop.');
    end
end

minRadius = computeMinTurnRadiusXY(positions, config.world.size);
assert(minRadius >= 150, 'XY trajectory turn radius too small (%.1f m).', minRadius);

disp('testFixedWingNoBounce passed.');

function minRadius = computeMinTurnRadiusXY(positions, worldSize)
minRadius = inf;
n = size(positions, 1);
edgeTol = 15;
for i = 3:(n - 2)
    p2 = positions(i, :);
    if nargin >= 2 && ~isempty(worldSize) && ...
            (p2(1) <= edgeTol || p2(2) <= edgeTol || ...
            p2(1) >= worldSize(1) - edgeTol || p2(2) >= worldSize(2) - edgeTol)
        continue;
    end
    p1 = positions(i - 2, :);
    p3 = positions(i + 2, :);
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

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
