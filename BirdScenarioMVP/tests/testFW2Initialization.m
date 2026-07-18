% testFW2Initialization - Проверки появления FW2 (ТЗ-09R).
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
fw2 = config.fixedWing2;
safe = fw2_getZoneBounds(config).SafeZone;

for i = 1:numel(uavs)
    u = uavs(i);
    assert(u.Position(3) > 0, 'Must start in air.');
    assert(norm(u.Velocity) >= fw2.speed.minSpeed, 'Speed must exceed minSpeed.');
    assert(string(u.State) == "Cruise", 'Initial state must be Cruise.');
    assert(u.RCS >= fw2.rcsRange(1) && u.RCS <= fw2.rcsRange(2), 'RCS out of range.');
    assert(all(u.Payload.RoutePoints(:, 1) >= safe(1)), 'Route X below safe zone.');
    assert(all(u.Payload.RoutePoints(:, 1) <= safe(2)), 'Route X above safe zone.');
    assert(isfield(u.Metadata, 'FW2') && u.Metadata.FW2, 'FW2 metadata required.');
end

disp('testFW2Initialization passed.');
