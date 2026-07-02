% testBirdRealismFields - Checks realism payload, history, and output fields (ТЗ-05E).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 30;
config.sim.dt = 1;
config.birds.fsm.enabled = true;
config.birds.realism.enabled = true;

[scenario, output] = runSimulation(config);

payloadFields = {'BehaviorProfile', 'RetargetCount', 'FlyByCount', ...
    'IsSharpManeuverActive', 'SharpManeuverEndTime', 'SharpManeuverDirection', ...
    'CircleBeforeLanding', 'CircleCenter', 'CircleRadius', 'CircleEndTime', ...
    'CircleDirection', 'LastRealismEvent'};
historyFields = {'BehaviorProfile', 'LastRealismEvent', 'RetargetCount', ...
    'FlyByCount', 'IsSharpManeuverActive', 'CircleBeforeLanding'};
outputFields = {'BehaviorProfile', 'LastRealismEvent', 'RetargetCount', ...
    'FlyByCount', 'IsSharpManeuverActive', 'CircleBeforeLanding'};

for i = 1:numel(scenario.Targets)
    payload = scenario.Targets(i).Payload;
    for f = 1:numel(payloadFields)
        assert(isfield(payload, payloadFields{f}), ...
            'Payload must have field: %s.', payloadFields{f});
    end

    history = scenario.Targets(i).History;
    for f = 1:numel(historyFields)
        assert(isfield(history, historyFields{f}), ...
            'History must have field: %s.', historyFields{f});
    end
end

for k = 1:numel(output)
    for i = 1:numel(output(k).Targets)
        targetOut = output(k).Targets(i);
        for f = 1:numel(outputFields)
            assert(isfield(targetOut, outputFields{f}), ...
                'Output must have field: %s.', outputFields{f});
        end
    end
end

disp('testBirdRealismFields passed.');
