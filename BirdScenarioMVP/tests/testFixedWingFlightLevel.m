% testFixedWingFlightLevel - Checks flight-level model (ТЗ-09B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.sim.duration = 80;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

assert(isfield(uav.Payload, 'FlightLevel'), 'FlightLevel required.');
assert(isfield(uav.Payload, 'TargetFlightLevel'), 'TargetFlightLevel required.');
levels = config.fixedWing.flightLevel.levelRange(1):config.fixedWing.flightLevel.levelSpacing: ...
    config.fixedWing.flightLevel.levelRange(2);
targetLevels = uav.History.TargetFlightLevel;
states = string(uav.History.State);
normalMask = ~ismember(states, ["Dive", "Recover"]);
assert(all(targetLevels(normalMask) >= config.fixedWing.flightLevel.levelRange(1) - 1e-6), ...
    'TargetFlightLevel below range.');
assert(all(targetLevels(normalMask) <= config.fixedWing.flightLevel.levelRange(2) + 1e-6), ...
    'TargetFlightLevel above range.');
assert(all(arrayfun(@(v) any(abs(levels - v) < 1e-6), targetLevels(normalMask))), ...
    'TargetFlightLevel must be one of configured levels.');

levelChanges = sum(abs(diff(targetLevels)) > 1e-6);
assert(levelChanges <= max(3, ceil(0.15 * numel(targetLevels))), ...
    'Flight level changes too often.');
waypointAltitudes = uav.Payload.Waypoints(:, 3);
assert(any(abs(targetLevels(1) - waypointAltitudes) > 1e-6), ...
    'Flight level should not be an exact copy of waypoint Z.');

disp('testFixedWingFlightLevel passed.');
