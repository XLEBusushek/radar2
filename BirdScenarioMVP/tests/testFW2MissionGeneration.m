% testFW2MissionGeneration - Генерация маршрута внутри безопасной зоны (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing.count = 0;
config.behavior.enabled = false;
setScenarioRNG(77);

pos = [1000; 1000; 200];
heading = 0;
mission = fw2_generateMission(pos, heading, config);
fw2 = config.fixedWing2;
safe = fw2_getZoneBounds(config).SafeZone;

assert(size(mission.RoutePoints, 1) >= fw2.route.waypointCountRange(1), 'Too few points.');
assert(size(mission.RoutePoints, 1) <= fw2.route.waypointCountRange(2), 'Too many points.');

points = [pos(1:2).'; mission.RoutePoints(:, 1:2)];
for j = 1:size(mission.RoutePoints, 1)
    assert(mission.RoutePoints(j, 1) >= safe(1) && mission.RoutePoints(j, 1) <= safe(2), 'X outside safe.');
    assert(mission.RoutePoints(j, 2) >= safe(3) && mission.RoutePoints(j, 2) <= safe(4), 'Y outside safe.');
end

lengths = vecnorm(diff(mission.RoutePoints(:, 1:2), 1, 1), 2, 2);
if ~isempty(lengths)
    assert(all(lengths >= fw2.route.minLegLength - 50), 'Leg too short.');
    assert(all(lengths <= fw2.route.maxLegLength + 1e-6), 'Leg too long.');
end

if size(mission.RoutePoints, 1) >= 3
    headings = atan2(diff(mission.RoutePoints(:, 2)), diff(mission.RoutePoints(:, 1)));
    changes = abs(arrayfun(@fw2_wrapAngle, diff(headings))) * 180 / pi;
    assert(all(changes <= fw2.route.maxHeadingChangeDeg + 1e-6), 'Turn too sharp.');
end

disp('testFW2MissionGeneration passed.');
