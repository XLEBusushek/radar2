% testFixedWingReturnHome - Checks ReturnHome final strategy (ТЗ-09C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 103;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.waypointCountRange = [3, 3];
config.fixedWing.finalPhase.strategyWeights.NewRoute = 0;
config.fixedWing.finalPhase.strategyWeights.Exit = 0;
config.fixedWing.finalPhase.strategyWeights.ReturnHome = 1;
config.fixedWing.finalPhase.strategyWeights.LoiterEnd = 0;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.fixedWing.finalPhase.routeProgressThreshold = 0.65;
config.sim.duration = 260;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

activeSteps = find(uav.History.FinalPhaseStarted);
assert(~isempty(activeSteps), 'ReturnHome strategy must enter final phase.');
assert(all(uav.History.FinalStrategy(activeSteps) == "ReturnHome"), ...
    'Simulation must use ReturnHome strategy during final phase.');
startIdx = activeSteps(1);
assert(any(uav.History.State(startIdx:end) == "ReturnHome"), ...
    'ReturnHome state must appear during final phase.');

home = uav.Payload.HomePosition(:);
finalPositions = uav.History.Position(startIdx:end, :);
distances = vecnorm(finalPositions(:, 1:2) - home(1:2).', 2, 2);
assert(any(distances <= config.fixedWing.finalPhase.homeArrivalRadius * 1.5) || ...
    any(uav.History.FinalMissionCompleted), ...
    'ReturnHome strategy must reach home or complete mission.');

disp('testFixedWingReturnHome passed.');
