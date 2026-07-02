% testBirdManeuverEvents - Checks cruise maneuver events (ТЗ-05C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 80;
config.sim.dt = 1;
config.birds.count = 10;
config.birds.fsm.enabled = true;
config.birds.curvedCruise.enabled = true;

config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;
config.birds.fsm.cruise.minTime = 15;
config.birds.fsm.cruise.maxTime = 70;
config.birds.fsm.cruise.landingProbability = 0.0;

[scenario, ~] = runSimulation(config);

foundLateralChange = false;
foundVerticalChange = false;
foundProgress = false;
foundWaypoint = false;

for i = 1:numel(scenario.Targets)
    target = scenario.Targets(i);
    states = string(target.History.State(:));
    cruiseIdx = find(states == "Cruise");

    if isempty(cruiseIdx)
        continue;
    end

    if isfield(target.History, 'CruiseLateralOffset')
        lateral = target.History.CruiseLateralOffset(cruiseIdx);
        if numel(unique(lateral)) > 1
            foundLateralChange = true;
        end
    end

    if isfield(target.History, 'CruiseVerticalOffset')
        vertical = target.History.CruiseVerticalOffset(cruiseIdx);
        if numel(unique(vertical)) > 1
            foundVerticalChange = true;
        end
    end

    if isfield(target.History, 'CruiseProgress')
        progress = target.History.CruiseProgress(cruiseIdx);
        if any(diff(progress) > 0)
            foundProgress = true;
        end
    end

    if isfield(target.History, 'CurveWaypoint')
        waypoints = target.History.CurveWaypoint(cruiseIdx, :);
        if any(~isnan(waypoints(:)))
            foundWaypoint = true;
        end
    end
end

assert(foundLateralChange, 'CruiseLateralOffset should change for some birds.');
assert(foundVerticalChange, 'CruiseVerticalOffset should change for some birds.');
assert(foundProgress, 'CruiseProgress should increase during Cruise.');
assert(foundWaypoint, 'CurveWaypoint must be set during Cruise.');

disp('testBirdManeuverEvents passed.');
