% testFW2NoHoverStop - Скорость всегда выше min, нет запрещённых состояний (ТЗ-09R).
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
config.sim.duration = 90;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(42);

[scenario, ~] = runSimulation(config);
for i = 1:numel(scenario.Targets)
    t = scenario.Targets(i);
    if t.Subtype ~= "fixedWingUAV"
        continue;
    end
    speeds = vecnorm(t.History.Velocity, 2, 2);
    assert(all(speeds >= config.fixedWing2.speed.minSpeed - 1), 'Speed dropped below min.');
    forbidden = ["Hover", "Idle", "Takeoff", "Landing", "Stop", "ExitArea"];
    assert(~any(ismember(string(t.History.State), forbidden)), 'Forbidden state detected.');
end

disp('testFW2NoHoverStop passed.');
