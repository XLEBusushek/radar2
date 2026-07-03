% testFW2AltitudeProfileInitialization - Flight level fields at spawn (ТЗ-09S).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 2;
config.fixedWing.count = 0;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
setScenarioRNG(42);

scenario = initializeScenario(config);
uavs = getScenarioFixedWingUAVs(scenario);
ap = config.fixedWing2.altitudeProfile;

for i = 1:numel(uavs)
    u = uavs(i);
    assert(isfield(u.Payload, 'CurrentFlightLevel'), 'Missing CurrentFlightLevel.');
    assert(isfield(u.Payload, 'TargetFlightLevel'), 'Missing TargetFlightLevel.');
    assert(u.Payload.CurrentFlightLevel >= ap.levelRange(1), 'CurrentFlightLevel too low.');
    assert(u.Payload.CurrentFlightLevel <= ap.levelRange(2), 'CurrentFlightLevel too high.');
    assert(u.Payload.TargetFlightLevel >= ap.levelRange(1), 'TargetFlightLevel too low.');
    assert(u.Payload.TargetFlightLevel <= ap.levelRange(2), 'TargetFlightLevel too high.');
    assert(u.Payload.AltitudeProfileEnabled, 'Altitude profile must be enabled.');
end

disp('testFW2AltitudeProfileInitialization passed.');
