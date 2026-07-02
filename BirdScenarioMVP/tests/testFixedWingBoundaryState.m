% testFixedWingBoundaryState - Checks boundary state fields (ТЗ-09D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 0;

worldSize = config.world.size;
[distanceInside, outsideInside] = computeDistanceToWorldBoundary([1000; 1000; 150], worldSize);
assert(distanceInside == 1000, 'DistanceToBoundary at center should be 1000.');
assert(~outsideInside, 'Center position must not be outside.');

[distanceEdge, outsideEdge] = computeDistanceToWorldBoundary([10; 1000; 150], worldSize);
assert(distanceEdge == 10, 'DistanceToBoundary near edge should be 10.');
assert(~outsideEdge, 'Inside edge position must not be outside.');

[~, outsideOut] = computeDistanceToWorldBoundary([-5; 1000; 150], worldSize);
assert(outsideOut, 'Negative X must be outside.');

config.fixedWing.count = 1;
setScenarioRNG(42);
scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);
uav.Position = [worldSize(1) - 20; 1000; uav.Position(3)];
uav = updateFixedWingBoundaryState(uav, config, 1);
assert(uav.Payload.NearBoundary, 'NearBoundary must activate near edge.');
assert(~uav.Payload.OutsideBoundary, 'Position still inside world bounds.');

disp('testFixedWingBoundaryState passed.');
