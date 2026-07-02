% testFixedWingLookaheadNavigation - Checks lookahead/corner cutting fields (ТЗ-09B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.navigation.cornerCuttingRadius = 250;
config.sim.dt = 1;

scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);
assert(size(uav.Payload.Waypoints, 1) >= 2, 'At least two waypoints required.');

currentWp = uav.Payload.CurrentWaypoint(:);
previousXY = uav.Payload.HomePosition(1:2);
approach = currentWp(1:2) - previousXY(:);
if norm(approach) < 1e-6
    approach = [1; 0];
else
    approach = approach / norm(approach);
end
uav.Position(1:2) = currentWp(1:2) - approach * (config.fixedWing.navigation.cornerCuttingRadius * 0.5);
uav.Position(3) = uav.Payload.TargetFlightLevel;
uav = computeFixedWingLookaheadPoint(uav, config);

assert(isfield(uav.History, 'NavigationLookaheadPoint'), ...
    'NavigationLookaheadPoint history required.');
assert(all(isfinite(uav.Payload.NavigationLookaheadPoint)), ...
    'NavigationLookaheadPoint must be finite.');
assert(islogical(uav.Payload.CornerCuttingActive), 'CornerCuttingActive must be logical.');
assert(uav.Payload.CornerCuttingActive, ...
    'Corner cutting should activate near at least one waypoint.');
nextWp = uav.Payload.Waypoints(2, :).';
assert(norm(uav.Payload.NavigationLookaheadPoint(1:2) - currentWp(1:2)) > 1, ...
    'Lookahead point should move beyond current waypoint.');
assert(norm(uav.Payload.NavigationLookaheadPoint(1:2) - nextWp(1:2)) < ...
    norm(currentWp(1:2) - nextWp(1:2)), ...
    'Lookahead point should blend toward next waypoint.');

disp('testFixedWingLookaheadNavigation passed.');
