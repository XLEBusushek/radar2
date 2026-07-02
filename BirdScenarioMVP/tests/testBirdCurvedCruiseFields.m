% testBirdCurvedCruiseFields - Checks curved cruise payload and output fields (ТЗ-05C).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
config.sim.duration = 30;
config.sim.dt = 1;
config.birds.fsm.enabled = true;
config.birds.fsm.perched.minTime = 1;
config.birds.fsm.perched.maxTime = 2;
config.birds.fsm.perched.takeoffProbability = 1.0;
config.birds.fsm.takeoff.minTime = 1;
config.birds.fsm.takeoff.maxTime = 2;
config.birds.fsm.takeoff.cruiseProbability = 1.0;

[scenario, output] = runSimulation(config);

payloadFields = {'CruiseStartPosition', 'CruiseTargetPosition', 'CruiseProgress', ...
    'CruiseLateralOffset', 'CruiseVerticalOffset', 'CruiseSideDirection', ...
    'LastManeuverPosition', 'NextManeuverDistance', 'CruisePhase', 'CurveWaypoint'};
outputFields = {'CruiseProgress', 'CruiseLateralOffset', ...
    'CruiseVerticalOffset', 'CurveWaypoint'};

for i = 1:numel(scenario.Targets)
    payload = scenario.Targets(i).Payload;
    for f = 1:numel(payloadFields)
        assert(isfield(payload, payloadFields{f}), ...
            'Payload must have field: %s.', payloadFields{f});
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

disp('testBirdCurvedCruiseFields passed.');
