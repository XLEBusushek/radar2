% testFixedWingFinalPhase - Checks final phase entry and strategy lock (ТЗ-09C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 77;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.waypointCountRange = [4, 4];
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.fixedWing.flightLevel.changeProbability = 0;
config.fixedWing.finalPhase.routeProgressThreshold = 0.75;
config.fixedWing.finalPhase.waypointsRemainingTrigger = 3;
config.sim.duration = 220;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

assert(any(uav.History.FinalPhaseStarted) || ...
    any(uav.History.LastNavigationEvent == "newRoute") || ...
    any(uav.History.LastNavigationEvent == "finalPhase:newRoute"), ...
    'Final phase must start before simulation ends.');
startIdx = find(uav.History.FinalPhaseStarted, 1, 'first');
activeSteps = find(uav.History.FinalPhaseStarted);
if ~isempty(activeSteps)
    initialStrategy = uav.History.FinalStrategy(activeSteps(1));
    assert(initialStrategy ~= "", 'Final strategy must be assigned.');
    assert(all(uav.History.FinalStrategy(activeSteps) == initialStrategy), ...
        'Final strategy must not change while final phase is active.');
end
assert(any(ismember(uav.History.State, ...
    ["ApproachExit", "AlignExit", "Exit", "LoiterEnd", "ReturnHome", "Cruise"])), ...
    'Final phase states must appear in history.');

disp('testFixedWingFinalPhase passed.');
