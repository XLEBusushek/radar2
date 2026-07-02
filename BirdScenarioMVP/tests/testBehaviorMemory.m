% testBehaviorMemory - Checks behavior memory is updated (ТЗ-07B).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = true;
config.behavior.decisionPeriodRange = [0.5, 0.5];
config.birds.realism.enabled = false;
config.sim.duration = 25;
config.sim.dt = 1;

[scenario, ~] = runSimulation(config);

foundMemory = false;
for i = 1:numel(scenario.Targets)
    memory = scenario.Targets(i).Behavior.Memory;
    if ~isempty(memory.RecentActions)
        foundMemory = true;
        assert(memory.LastAction ~= "", 'LastAction must be recorded.');
        assert(~isempty(fieldnames(memory.ActionCounts)), 'ActionCounts must be populated.');
        assert(any(struct2array(memory.ActionCounts) > 0), 'ActionCounts must increase.');
    end
end

assert(foundMemory, 'At least one target must record behavior memory.');
disp('testBehaviorMemory passed.');
