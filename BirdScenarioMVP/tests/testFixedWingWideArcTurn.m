% testFixedWingWideArcTurn - Checks ~300 m fly-by arc on controlled 90-degree turn (ТЗ-09H).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 91;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.fixedWing.navigation.arcTurnEnabled = true;
config.sim.duration = 120;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

setScenarioRNG(config.sim.random.seed);
scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

alt = uav.Payload.FlightLevel;
waypoints = [
    700, 1000, alt
    1200, 1000, alt
    1200, 1500, alt
];
uav.Payload.Waypoints = waypoints;
uav.Payload.CurrentWaypointIndex = 2;
uav.Payload.CurrentWaypoint = waypoints(2, :).';
uav.Position = [850; 1000; alt];
speed = mean(config.fixedWing.cruiseSpeedRange);
uav.Velocity = [speed; 0; 0];
uav.Payload.CurrentHeading = 0;
uav.Payload.SmoothedHeading = 0;
uav.Payload.TimeOnCurrentLeg = config.fixedWing.antiBounce.minTimeOnLeg;
uav.Payload.MissionComplete = false;
uav.History.Position = uav.Position.';
uav.History.Velocity = uav.Velocity.';
uav.History.CurrentHeading = uav.Payload.CurrentHeading;
uav = appendTargetHistory(uav);

for k = 1:config.sim.duration
    uav = updateTarget(uav, scenario, config, config.sim.dt);
end

positions = uav.History.Position(:, 1:2);
headings = uav.History.CurrentHeading(:);
turnStart = find(abs(headings) * 180 / pi > 10, 1, 'first');
assert(~isempty(turnStart), 'Aircraft must begin turning toward the next leg.');
assert(max(positions(turnStart:end, 2)) > positions(turnStart, 2) + 100, ...
    'Wide arc must progress north toward the next waypoint.');

turnEnd = min(turnStart + 60, size(positions, 1));
minRadius = computeMinTurnRadiusXY(positions(turnStart:turnEnd, :), config.world.size);
assert(minRadius >= 250, 'Wide arc turn radius too small (%.1f m).', minRadius);

disp('testFixedWingWideArcTurn passed.');

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
    if a < 20 || b < 20
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
