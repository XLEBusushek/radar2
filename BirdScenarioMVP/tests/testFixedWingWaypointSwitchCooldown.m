% testFixedWingWaypointSwitchCooldown - Checks waypoint switch timing (ТЗ-09F).
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
config.fixedWing.diveProbability = 0;
config.fixedWing.returnProbability = 0;
config.sim.duration = 220;
config.sim.dt = 1;
config.visualization.enabled = false;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

cooldown = config.fixedWing.antiBounce.waypointSwitchCooldown;
minLeg = config.fixedWing.antiBounce.minTimeOnLeg;
idx = uav.History.WaypointIndex;
changes = find(diff(idx) ~= 0);
times = uav.History.Time;
for c = 2:numel(changes)
    dtSwitch = times(changes(c) + 1) - times(changes(c - 1) + 1);
    assert(dtSwitch >= cooldown - config.sim.dt, ...
        'Waypoint switched faster than waypointSwitchCooldown.');
end

arrivalRadius = config.fixedWing.navigation.arrivalRadius;
for k = 2:numel(changes)
    step = changes(k) + 1;
    if step <= numel(uav.History.WaypointReached) && uav.History.WaypointReached(step)
        continue;
    end
    legStart = changes(k - 1) + 1;
    legDuration = times(step) - times(legStart);
    assert(legDuration >= minLeg - config.sim.dt || uav.History.WaypointReached(step), ...
        'Waypoint switched before minTimeOnLeg without arrival.');
end

assert(any(uav.History.TimeOnCurrentLeg >= 0), 'TimeOnCurrentLeg must be recorded.');

disp('testFixedWingWaypointSwitchCooldown passed.');
