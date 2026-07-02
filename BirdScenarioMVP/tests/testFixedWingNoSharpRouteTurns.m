% testFixedWingNoSharpRouteTurns - Checks route turn limits (ТЗ-09D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 88;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 3;
setScenarioRNG(88);

scenario = initializeScenario(config);
fixedWing = getScenarioFixedWingUAVs(scenario);
maxTurn = config.fixedWing.navigation.maxHeadingChangeDeg + 1;

for i = 1:numel(fixedWing)
    points = [fixedWing(i).Payload.HomePosition(:).'; fixedWing(i).Payload.Waypoints];
    if size(points, 1) < 3
        continue;
    end
    headings = atan2(diff(points(:, 2)), diff(points(:, 1)));
    headingChanges = abs(arrayfun(@wrapToPiLocal, diff(headings))) * 180 / pi;
    assert(all(headingChanges <= maxTurn), 'Route must not contain sharp turns.');
end

disp('testFixedWingNoSharpRouteTurns passed.');

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
