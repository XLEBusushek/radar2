% testFixedWingNoChaoticCircles - Ensures no heading churn near mission end (ТЗ-09C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.waypointCountRange = [4, 4];
config.fixedWing.finalPhase.routeProgressThreshold = 0.7;
config.fixedWing.finalPhase.waypointsRemainingTrigger = 3;
config.fixedWing.finalPhase.strategyWeights.NewRoute = 0;
config.fixedWing.finalPhase.strategyWeights.Exit = 0;
config.fixedWing.finalPhase.strategyWeights.ReturnHome = 1;
config.fixedWing.finalPhase.strategyWeights.LoiterEnd = 0;
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.fixedWing.flightLevel.changeProbability = 0;
config.sim.duration = 260;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

startIdx = find(uav.History.FinalPhaseStarted, 1, 'first');
if isempty(startIdx)
    startIdx = find(uav.History.LastNavigationEvent == "finalPhase:newRoute", 1, 'first');
end
assert(~isempty(startIdx), 'Final phase must start to validate end-of-mission behavior.');

headings = unwrap(uav.History.CurrentHeading(startIdx:end));
headingRateDeg = abs(diff(headings)) * 180 / pi / config.sim.dt;
maxTurnRate = config.fixedWing.finalPhase.maxTurnRateDeg + 2.5;
assert(all(headingRateDeg(3:end) <= maxTurnRate | isnan(headingRateDeg(3:end))), ...
    'Final phase heading changes exceed allowed turn rate.');

positions = uav.History.Position(startIdx:end, 1:2);
states = uav.History.State(startIdx:end);
localRadius = 50;
localWindow = 15;
for k = 1:(size(positions, 1) - localWindow)
    if states(k) == "LoiterEnd"
        continue;
    end
    segment = positions(k:(k + localWindow), :);
    center = mean(segment, 1);
    if all(vecnorm(segment - center, 2, 2) <= localRadius)
        error('Fixed-wing UAV formed a chaotic local loop during final phase.');
    end
end

disp('testFixedWingNoChaoticCircles passed.');
