% testFixedWingExit - Checks Exit strategy leaves the map smoothly (ТЗ-09C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 91;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.allowExitArea = true;
config.fixedWing.waypointCountRange = [3, 3];
config.fixedWing.finalPhase.strategyWeights.Exit = 1;
config.fixedWing.finalPhase.strategyWeights.ReturnHome = 0;
config.fixedWing.finalPhase.strategyWeights.LoiterEnd = 0;
config.fixedWing.finalPhase.routeProgressThreshold = 0.6;
config.sim.duration = 260;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

assert(all(uav.History.FinalStrategy == "Exit"), 'Simulation must use Exit strategy.');
startIdx = find(uav.History.FinalPhaseStarted, 1, 'first');
assert(~isempty(startIdx), 'Exit strategy must enter final phase.');
finalStates = uav.History.State(startIdx:end);
assert(any(finalStates == "ApproachExit" | finalStates == "AlignExit" | finalStates == "Exit"), ...
    'Exit strategy must use final exit states.');

worldSize = config.world.size;
margin = config.fixedWing.finalPhase.exitBoundaryMargin;
positions = uav.History.Position(startIdx:end, :);
exited = any(positions(:, 1) < -margin | positions(:, 1) > worldSize(1) + margin | ...
    positions(:, 2) < -margin | positions(:, 2) > worldSize(2) + margin);
completed = any(uav.History.FinalMissionCompleted);
assert(exited || completed, 'Exit strategy must leave the map or mark mission complete.');

disp('testFixedWingExit passed.');
