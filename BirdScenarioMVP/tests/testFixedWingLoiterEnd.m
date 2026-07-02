% testFixedWingLoiterEnd - Checks one large end-of-mission loiter circle (ТЗ-09C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 117;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.waypointCountRange = [3, 3];
config.fixedWing.finalPhase.strategyWeights.NewRoute = 0;
config.fixedWing.finalPhase.strategyWeights.Exit = 0;
config.fixedWing.finalPhase.strategyWeights.ReturnHome = 0;
config.fixedWing.finalPhase.strategyWeights.LoiterEnd = 1;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.fixedWing.finalPhase.loiterEndRadiusRange = [280, 320];
config.fixedWing.finalPhase.routeProgressThreshold = 0.65;
config.sim.duration = 320;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

activeSteps = find(uav.History.FinalPhaseStarted);
assert(~isempty(activeSteps), 'LoiterEnd strategy must enter final phase.');
assert(all(uav.History.FinalStrategy(activeSteps) == "LoiterEnd"), ...
    'Simulation must keep LoiterEnd strategy during final phase.');
startIdx = activeSteps(1);
loiterStates = uav.History.State(startIdx:end) == "LoiterEnd";
assert(any(loiterStates), 'LoiterEnd state must occur.');
assert(any(uav.History.State(startIdx:end) == "ApproachExit") || ...
    any(uav.History.FinalMissionCompleted) || ...
    any(uav.History.LastNavigationEvent == "newRoute") || ...
    any(uav.History.LastNavigationEvent == "finalPhase:newRoute") || ...
    any(uav.History.LastNavigationEvent == "finalPhase:loiterEndNewRoute") || ...
    uav.Payload.LoiterEndCompleted, ...
    'LoiterEnd must continue to exit/home/new route after one loop.');

disp('testFixedWingLoiterEnd passed.');
