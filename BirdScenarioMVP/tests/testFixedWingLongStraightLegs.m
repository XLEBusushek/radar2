% testFixedWingLongStraightLegs - Checks long straight route legs (ТЗ-09D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 77;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 3;
setScenarioRNG(77);

scenario = initializeScenario(config);
fixedWing = getScenarioFixedWingUAVs(scenario);
minLeg = config.fixedWing.navigation.minStraightLegLength;

for i = 1:numel(fixedWing)
    points = [fixedWing(i).Payload.HomePosition(:).'; fixedWing(i).Payload.Waypoints];
    segmentLengths = vecnorm(diff(points(:, 1:2), 1, 1), 2, 2);
    assert(all(segmentLengths >= minLeg - 1e-6), 'Route legs must be long straight segments.');
end

disp('testFixedWingLongStraightLegs passed.');
