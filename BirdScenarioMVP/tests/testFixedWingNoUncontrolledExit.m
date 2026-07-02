% testFixedWingNoUncontrolledExit - Ensures fixed-wing stays in bounds (ТЗ-09D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 2;
config.fixedWing.allowExitArea = false;
config.sim.duration = 300;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;

[scenario, ~] = runSimulation(config);
worldSize = config.world.size;
tolerance = 1;

for i = 1:numel(scenario.Targets)
    if scenario.Targets(i).Subtype ~= "fixedWingUAV"
        continue;
    end
    positions = scenario.Targets(i).History.Position;
    assert(all(positions(:, 1) >= -tolerance & positions(:, 1) <= worldSize(1) + tolerance), ...
        'Fixed-wing X must stay inside world bounds.');
    assert(all(positions(:, 2) >= -tolerance & positions(:, 2) <= worldSize(2) + tolerance), ...
        'Fixed-wing Y must stay inside world bounds.');
end

disp('testFixedWingNoUncontrolledExit passed.');
