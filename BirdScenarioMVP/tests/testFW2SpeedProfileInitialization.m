% testFW2SpeedProfileInitialization - Speed profile fields at spawn (ТЗ-09S).
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
sp = config.fixedWing2.speedProfile;
fw2 = config.fixedWing2;

for i = 1:numel(uavs)
    u = uavs(i);
    assert(u.Payload.BaseCruiseSpeed >= sp.cruiseSpeedRange(1), 'BaseCruiseSpeed too low.');
    assert(u.Payload.BaseCruiseSpeed <= sp.cruiseSpeedRange(2), 'BaseCruiseSpeed too high.');
    assert(u.Payload.TargetSpeed >= fw2.speed.minSpeed, 'TargetSpeed below minSpeed.');
    assert(u.Payload.TargetSpeed <= fw2.speed.maxSpeed, 'TargetSpeed above maxSpeed.');
    assert(u.Payload.CurrentSpeed >= fw2.speed.minSpeed, 'CurrentSpeed below minSpeed.');
    assert(u.Payload.SpeedProfileEnabled, 'Speed profile must be enabled.');
end

disp('testFW2SpeedProfileInitialization passed.');
