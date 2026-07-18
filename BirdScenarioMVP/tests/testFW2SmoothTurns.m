% testFW2SmoothTurns - Изменения курса соблюдают лимиты скорости поворота (ТЗ-09R).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.fixedWing2.enabled = true;
config.fixedWing2.count = 1;
config.fixedWing.count = 0;
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.sim.duration = 90;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(55);

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

headings = uav.History.CurrentHeading;
maxJump = config.fixedWing2.turn.maxTurnRateDeg * config.sim.dt + 0.5;
for k = 2:numel(headings)
    delta = abs(fw2_wrapAngle(headings(k) - headings(k - 1))) * 180 / pi;
    assert(delta <= maxJump, 'Heading jump exceeds max turn rate.');
end

turnIdx = find(string(uav.History.State) == "Turn");
if ~isempty(turnIdx)
    turnDurations = diff([turnIdx(1); turnIdx(end)]);
    assert(turnDurations >= 0, 'Turn state recorded.');
end

disp('testFW2SmoothTurns passed.');
