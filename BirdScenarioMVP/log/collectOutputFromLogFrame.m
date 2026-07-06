function outputStep = collectOutputFromLogFrame(frame, trajectoryLog, config)
% collectOutputFromLogFrame - Build legacy output step from a TrajectoryLog frame.
arguments
    frame (1, 1) struct
    trajectoryLog (1, 1) struct
    config (1, 1) struct
end

scenario = struct();
scenario.Time = frame.Time;
scenario.Targets = struct([]);

if isfield(frame, 'Targets') && ~isempty(frame.Targets)
    scenario.Targets = logTargetToSimTarget(frame.Targets(1), frame.Time);
    for i = 2:numel(frame.Targets)
        scenario.Targets(i) = logTargetToSimTarget(frame.Targets(i), frame.Time);
    end
end

if isfield(trajectoryLog, 'SimulationInfo')
    info = trajectoryLog.SimulationInfo;
    scenario.Metadata.RandomMode = string(getLogInfoField(info, 'RandomMode', ""));
    scenario.Metadata.ScenarioSeed = getLogInfoField(info, 'Seed', nan);
end

outputStep = collectOutput(scenario, frame.Time);
end

function value = getLogInfoField(info, name, defaultValue)
if isfield(info, name)
    value = info.(name);
else
    value = defaultValue;
end
end
