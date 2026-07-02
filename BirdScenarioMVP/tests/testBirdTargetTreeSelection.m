% testBirdTargetTreeSelection - Checks target tree selection in FSM (ТЗ-05A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 120;
config.sim.dt = 1;
config.birds.fsm.enabled = true;
config.birds.landing.enabled = true;
config.birds.landing.approachRadius = 2000;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 1;
config.birds.fsm.cruise.maxTime = 60;
config.birds.fsm.cruise.landingProbability = 0.0;
config.birds.fsm.landing.minTime = 1;
config.birds.fsm.landing.maxTime = 30;
config.birds.fsm.landing.hiddenProbability = 1.0;
config.birds.fsm.hidden.minTime = 1;
config.birds.fsm.hidden.maxTime = 2;
config.birds.fsm.hidden.perchedProbability = 1.0;

[scenario, output] = runSimulation(config);
treeIDs = [scenario.Trees.ID];

foundTakeoff = false;
foundHidden = false;

for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        targetOut = output(k).Targets(i);

        if targetOut.State == "Takeoff"
            foundTakeoff = true;
            assert(~isempty(targetOut.TargetTreeID), ...
                'TargetTreeID must be set during Takeoff.');
            assert(targetOut.TargetTreeID ~= targetOut.CurrentTreeID, ...
                'TargetTreeID must differ from CurrentTreeID.');
            assert(ismember(targetOut.TargetTreeID, treeIDs), ...
                'TargetTreeID must reference an existing tree.');
        end

        if targetOut.State == "Hidden"
            foundHidden = true;
            assert(isempty(targetOut.TargetTreeID), ...
                'TargetTreeID must be cleared in Hidden state.');
            assert(ismember(targetOut.CurrentTreeID, treeIDs), ...
                'CurrentTreeID must reference an existing tree.');
            assert(targetOut.Visible == false, ...
                'Bird must not be visible in Hidden state.');

            treeIdx = find(treeIDs == targetOut.CurrentTreeID, 1);
            tree = scenario.Trees(treeIdx);
            distXY = norm(targetOut.Position(1:2) - tree.Position(1:2));
            assert(distXY <= tree.CrownRadius * 1.5, ...
                'Bird must be near the crown of CurrentTreeID.');
        end
    end
end

assert(foundTakeoff, 'Simulation must include Takeoff state.');
assert(foundHidden, 'Simulation must include Hidden state.');

disp('testBirdTargetTreeSelection passed.');
