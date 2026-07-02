% testBirdRetargeting - Checks in-flight retarget behavior (ТЗ-05E).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 120;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.birds.realism.enabled = true;
config.birds.realism.retargetProbability = 0.5;
config.birds.realism.flyByProbability = 0.0;
config.birds.realism.circleBeforeLandingProbability = 0.0;
config.birds.realism.sharpManeuverProbability = 0.0;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 5;
config.birds.fsm.cruise.maxTime = 100;
config.birds.fsm.cruise.landingProbability = 0.0;

[scenario, ~] = runSimulation(config);

foundRetarget = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    history = target.History;

    assert(all(~isnan(history.Position(:))), 'Position must not contain NaN.');
    assert(all(~isinf(history.Position(:))), 'Position must not contain Inf.');
    assert(all(~isnan(history.Velocity(:))), 'Velocity must not contain NaN.');
    assert(all(~isinf(history.Velocity(:))), 'Velocity must not contain Inf.');

    if target.Payload.RetargetCount > 0
        foundRetarget = true;
        if ~isempty(target.Payload.TargetTreeID) && ~isempty(target.Payload.CurrentTreeID)
            assert(target.Payload.TargetTreeID ~= target.Payload.CurrentTreeID, ...
                'Retargeted bird in cruise must fly toward a different target tree.');
        end
    end
end

assert(foundRetarget, 'At least one bird must retarget during cruise.');

disp('testBirdRetargeting passed.');
