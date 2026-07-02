% testBirdProgressToTarget - Checks ForceDirectToTarget progress recovery (ТЗ-06C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 120;
config.sim.dt = 1;
config.birds.count = 5;
config.birds.fsm.enabled = true;
config.birds.realism.enabled = true;
config.birds.realism.noProgressTimeLimit = 6;
config.birds.realism.flyByProbability = 0.0;
config.birds.realism.retargetProbability = 0.0;
config.birds.realism.circleBeforeLandingProbability = 1.0;
config.birds.realism.sharpManeuverProbability = 0.0;
config.birds.curvedCruise.directionChangeProbability = 0.0;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 20;
config.birds.fsm.cruise.maxTime = 100;
config.birds.fsm.cruise.landingProbability = 0.0;

[scenario, ~] = runSimulation(config);

foundForceDirect = false;
foundApproachAfterForce = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);

    if isfield(target.History, 'LastRealismEvent') && ...
            any(string(target.History.LastRealismEvent) == "forceDirect")
        foundForceDirect = true;
    end

    distances = target.History.DistanceToTargetTree;
    if ~isempty(distances)
        validDist = distances(~isnan(distances));
        if numel(validDist) >= 2 && validDist(end) < validDist(1)
            foundApproachAfterForce = true;
        end
    end
end

assert(foundForceDirect, 'ForceDirectToTarget must activate for at least one bird.');
assert(foundApproachAfterForce, ...
    'At least one bird must continue approaching its target after direct mode.');

disp('testBirdProgressToTarget passed.');
