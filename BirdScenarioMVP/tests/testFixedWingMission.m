% testFixedWingMission - Checks fixed-wing UAV waypoint mission (ТЗ-09A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 2;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
fixedWing = getScenarioFixedWingUAVs(scenario);
fw = config.fixedWing;

for i = 1:numel(fixedWing)
    waypoints = fixedWing(i).Payload.Waypoints;
    assert(size(waypoints, 1) >= fw.waypointCountRange(1), 'Too few waypoints.');
    assert(size(waypoints, 1) <= fw.waypointCountRange(2), 'Too many waypoints.');
    assert(all(waypoints(:, 3) >= fw.operatingAltitudeRange(1)), 'Waypoint altitude low.');
    assert(all(waypoints(:, 3) <= fw.operatingAltitudeRange(2)), 'Waypoint altitude high.');

    points = [fixedWing(i).Payload.HomePosition(:).'; waypoints];
    segmentLengths = vecnorm(diff(points(:, 1:2), 1, 1), 2, 2);
    minLeg = fw.navigation.minStraightLegLength;
    assert(all(segmentLengths >= minLeg - 1e-6), 'Waypoint segment too short.');
    assert(all(segmentLengths <= fw.navigation.maxStraightLegLength + 1e-6), 'Waypoint segment too long.');
    margin = fw.navigation.minWaypointBoundaryMargin;
    assert(all(waypoints(:, 1) >= margin & waypoints(:, 1) <= config.world.size(1) - margin), ...
        'Waypoint X too close to boundary.');
    assert(all(waypoints(:, 2) >= margin & waypoints(:, 2) <= config.world.size(2) - margin), ...
        'Waypoint Y too close to boundary.');

    if size(points, 1) >= 3
        headings = atan2(diff(points(:, 2)), diff(points(:, 1)));
        headingChanges = abs(arrayfun(@wrapToPiLocal, diff(headings)));
        assert(all(headingChanges <= deg2rad(fw.navigation.maxHeadingChangeDeg + 5)), ...
            'Route contains a near-right-angle turn.');
    end
end

disp('testFixedWingMission passed.');

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
