% testFixedWingWaypointArcTurn - Checks fly-by arc turns at waypoints (ТЗ-09G).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 88;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.fixedWing.navigation.arcTurnEnabled = true;
config.fixedWing.finalPhase.enabled = false;
config.sim.duration = 180;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

assert(config.fixedWing.navigation.arcTurnEnabled, 'Arc turn must be enabled in config.');

positions = uav.History.Position(:, 1:2);
minRadius = computeMinTurnRadiusXY(positions, config.world.size, uav.History);
assert(minRadius >= 180, 'Arc turn radius too small (%.1f m).', minRadius);

disp('testFixedWingWaypointArcTurn passed.');

function minRadius = computeMinTurnRadiusXY(positions, worldSize, history)
minRadius = inf;
n = size(positions, 1);
edgeTol = 15;
for i = 3:(n - 2)
    if nargin >= 3 && ~isempty(history)
        if isfield(history, 'BoundaryRecoveryActive') && history.BoundaryRecoveryActive(i)
            continue;
        end
        if isfield(history, 'FinalPhaseStarted') && history.FinalPhaseStarted(i)
            continue;
        end
    end
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
