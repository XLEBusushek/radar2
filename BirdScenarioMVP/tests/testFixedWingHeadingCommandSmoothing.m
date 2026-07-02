% testFixedWingHeadingCommandSmoothing - Checks heading command smoothing (ТЗ-09F).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.sim.duration = 60;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

maxJump = config.fixedWing.antiBounce.maxHeadingJumpDeg + 0.5;
assert(all(uav.History.HeadingJumpDeg <= maxJump | isnan(uav.History.HeadingJumpDeg)), ...
    'HeadingJumpDeg exceeds maxHeadingJumpDeg.');

smooth = uav.History.SmoothedTargetHeading;
smoothDelta = abs(arrayfun(@wrapToPiLocal, diff(smooth))) * 180 / pi;
assert(all(smoothDelta <= maxJump | isnan(smoothDelta)), ...
    'SmoothedTargetHeading changes too sharply.');

disp('testFixedWingHeadingCommandSmoothing passed.');

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
