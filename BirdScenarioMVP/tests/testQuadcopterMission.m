% testQuadcopterMission - Проверяет waypoints миссии квадрокоптера (ТЗ-07A).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 3;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
worldSize = config.world.size;
altRange = config.quadcopter.operatingAltitudeRange;
wpRange = config.quadcopter.waypointCountRange;

quadcopters = getScenarioQuadcopters(scenario);
for i = 1:numel(quadcopters)
    qc = quadcopters(i);
    assert(isfield(qc.Payload, 'HomePosition'), 'HomePosition required.');
    assert(isfield(qc.Payload, 'Waypoints'), 'Waypoints required.');
    assert(isequal(qc.Payload.HomePosition(:), qc.History.Position(1, :).'), ...
        'HomePosition must match start.');

    numWp = size(qc.Payload.Waypoints, 1);
    assert(numWp >= wpRange(1) && numWp <= wpRange(2), 'Waypoint count out of range.');

    for w = 1:numWp
        wp = qc.Payload.Waypoints(w, :);
        assert(wp(1) >= 0 && wp(1) <= worldSize(1), 'Waypoint X out of bounds.');
        assert(wp(2) >= 0 && wp(2) <= worldSize(2), 'Waypoint Y out of bounds.');
        assert(wp(3) >= altRange(1) && wp(3) <= altRange(2), 'Waypoint Z out of range.');
    end
end

disp('testQuadcopterMission passed.');
