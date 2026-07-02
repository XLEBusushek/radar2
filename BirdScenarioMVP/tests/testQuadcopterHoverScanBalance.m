% testQuadcopterHoverScanBalance - Checks Hover/Scan are bounded events (ТЗ-07C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 8;
config.quadcopter.waypointCountRange = [6, 6];
config.quadcopter.transitSpeedRange = [14, 18];
config.quadcopter.waypointArrivalRadius = 25;
config.quadcopter.fsm.idle.maxTime = 1;
config.quadcopter.fsm.idle.takeoffProbability = 1.0;
config.sim.duration = 420;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
config.debug.verbose = false;

[scenario, ~] = runSimulation(config);
quadcopters = getScenarioQuadcopters(scenario);

hoverScanCount = 0;
transitCount = 0;
totalCount = 0;
hasHover = false;
hasScan = false;

for i = 1:numel(quadcopters)
    states = string(quadcopters(i).History.State);
    hasHover = hasHover || any(states == "Hover");
    hasScan = hasScan || any(states == "Scan");
    hoverScanCount = hoverScanCount + sum(states == "Hover" | states == "Scan");
    transitCount = transitCount + sum(states == "Transit");
    totalCount = totalCount + numel(states);
end

assert(hasHover, 'Hover must occur for at least one quadcopter.');
assert(hasScan, 'Scan must occur for at least one quadcopter.');
assert(hoverScanCount / totalCount <= 0.50, 'Hover+Scan must not dominate simulation.');
assert(transitCount / totalCount >= 0.20, 'Transit must occupy a meaningful share.');

disp('testQuadcopterHoverScanBalance passed.');
