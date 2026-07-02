% testFixedWingLookaheadSmoothing - Checks smoothed lookahead limits (ТЗ-09F).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.birds.count = 0;
config.quadcopter.count = 0;
config.groundVehicle.count = 0;
config.fixedWing.count = 1;
config.fixedWing.fsm.enabled = false;
config.sim.duration = 80;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);
uav = getScenarioFixedWingUAVs(scenario);
uav = uav(1);

maxJump = config.fixedWing.antiBounce.maxTargetPointJump + 5;
assert(all(uav.History.TargetPointJump <= maxJump | isnan(uav.History.TargetPointJump)), ...
    'TargetPointJump exceeds configured limit.');

smooth = uav.History.SmoothedLookaheadPoint;
raw = uav.History.RawLookaheadPoint;
for k = 2:size(smooth, 1)
    if any(isnan(smooth(k, :))) || any(isnan(smooth(k - 1, :)))
        continue;
    end
    stepJump = norm(smooth(k, 1:2) - smooth(k - 1, 1:2));
    assert(stepJump <= maxJump + config.fixedWing.minSpeed * config.sim.dt + 5, ...
        'SmoothedLookaheadPoint step jump too large.');
end

assert(any(all(isfinite(raw), 2)), 'RawLookaheadPoint must be recorded.');
assert(any(all(isfinite(smooth), 2)), 'SmoothedLookaheadPoint must be recorded.');

disp('testFixedWingLookaheadSmoothing passed.');
