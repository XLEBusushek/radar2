% testFW2NoWaypointAttraction - No backward turn after passing waypoint (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 1;
config.fixedWing.count = 0;
config.behavior.enabled = false;
setScenarioRNG(42);

scenario = initializeScenario(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

legEnd = uav.Payload.CurrentLegEnd(:);
legStart = uav.Payload.CurrentLegStart(:);
legXY = legEnd(1:2) - legStart(1:2);
if norm(legXY) > 1e-6
    legDir = legXY / norm(legXY);
else
    legDir = [cos(uav.Payload.CurrentHeading); sin(uav.Payload.CurrentHeading)];
end
pastPoint = [legEnd(1:2) + legDir * 300; legEnd(3)];
uav.Position = pastPoint;
uav.Payload.CurrentLegProgress = 1.2;
uav = fw2_updateMissionState(uav, config);

assert(uav.Payload.RouteIndex > 1 || uav.Payload.RouteComplete, ...
    'Leg must complete without backward attraction.');
headingErr = uav.Payload.HeadingErrorDeg;
assert(abs(headingErr) < 120, 'Must not turn sharply backward to waypoint.');

disp('testFW2NoWaypointAttraction passed.');
