% testBehaviorProfiles - Checks Behavior profile initialization (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.birds.realism.enabled = false;
config.sim.duration = 5;
config.sim.dt = 1;
setScenarioRNG(config.sim.random.seed);

scenario = initializeScenario(config);
targets = scenario.Targets;

allowedBirdProfiles = ["bird_normal", "bird_cautious", "bird_active"];
allowedQuadProfiles = ["quad_recon", "quad_calm", "quad_aggressive", "quad_observer"];
periodRange = config.behavior.decisionPeriodRange;
personalityFields = {'Randomness', 'MissionFocus', 'Curiosity', 'Caution', ...
    'SpeedBias', 'AltitudeBias', 'HoverBias', 'ScanBias', 'ReturnBias', ...
    'ManeuverBias'};

for i = 1:numel(targets)
    target = targets(i);
    assert(isfield(target, 'Behavior'), 'Target must have Behavior.');
    assert(isfield(target.Behavior, 'Profile'), 'Behavior must have Profile.');
    assert(isfield(target.Behavior, 'Personality'), 'Behavior must have Personality.');
    assert(isfield(target.Behavior, 'Memory'), 'Behavior must have Memory.');

    profile = string(target.Behavior.Profile);
    if target.Class == "bird"
        assert(any(profile == allowedBirdProfiles), 'Unexpected bird profile.');
    else
        assert(any(profile == allowedQuadProfiles), 'Unexpected quadcopter profile.');
    end

    for f = 1:numel(personalityFields)
        value = target.Behavior.Personality.(personalityFields{f});
        assert(value >= 0.5 && value <= 1.5, 'Personality coefficient out of range.');
    end

    period = target.Behavior.DecisionPeriod;
    assert(period >= periodRange(1) && period <= periodRange(2), ...
        'DecisionPeriod out of range.');
end

disp('testBehaviorProfiles passed.');
