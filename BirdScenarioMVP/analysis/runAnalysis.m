function result = runAnalysis(trajectoryLog, config)
% runAnalysis - Compute statistics and metrics from TrajectoryLog only.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct = struct()
end

result = struct();
result.Statistics = computeLogStatistics(trajectoryLog);
result.Metrics = computeLogMetrics(trajectoryLog);
result.Events = computeLogEvents(trajectoryLog);
result.Distributions = computeLogDistributions(trajectoryLog);
result.Summary = buildLogAnalysisSummary(result, trajectoryLog, config);
end

function stats = computeLogStatistics(log)
stats = struct();
stats.Duration = 0;
stats.TimeStep = nan;
stats.Seed = nan;
stats.FrameCount = 0;
stats.TargetCount = 0;
stats.BirdCount = 0;
stats.QuadcopterCount = 0;
stats.FixedWingCount = 0;
stats.GroundVehicleCount = 0;

if isfield(log, 'SimulationInfo')
    stats.Duration = getField(log.SimulationInfo, 'Duration', 0);
    stats.TimeStep = getField(log.SimulationInfo, 'TimeStep', nan);
    stats.Seed = getField(log.SimulationInfo, 'Seed', nan);
end
if isfield(log, 'Frames')
    stats.FrameCount = numel(log.Frames);
end

ids = getUniqueTargetIds(log);
stats.TargetCount = numel(ids);
stats.BirdCount = numel(getUniqueTargetIds(log, "bird", ""));
stats.QuadcopterCount = numel(getUniqueTargetIds(log, "air", "quadcopter"));
stats.FixedWingCount = numel(getUniqueTargetIds(log, "air", "fixedWingUAV"));
stats.GroundVehicleCount = numel(getUniqueTargetIds(log, "ground", "vehicle"));
end

function metrics = computeLogMetrics(log)
metrics = struct('TargetID', {}, 'Class', {}, 'Subtype', {}, ...
    'MaxSpeed', {}, 'MeanSpeed', {}, 'MaxAltitude', {}, 'MinAltitude', {}, ...
    'MeanRCS', {}, 'VisibleFraction', {}, 'StateChangeCount', {});

ids = getUniqueTargetIds(log);
for id = ids(:).'
    history = buildTargetHistoryFromLog(log, id);
    if isempty(history.Time)
        continue;
    end
    meta = getTargetMetaFromLog(log, id);
    speeds = vecnorm(history.Velocity, 2, 2);
    altitudes = history.Position(:, 3);
    states = string(history.State);
    stateChanges = sum(states(2:end) ~= states(1:end-1));

    m.TargetID = id;
    m.Class = meta.Type;
    m.Subtype = meta.Subtype;
    m.MaxSpeed = max(speeds);
    m.MeanSpeed = mean(speeds);
    m.MaxAltitude = max(altitudes);
    m.MinAltitude = min(altitudes);
    m.MeanRCS = mean(history.RCS);
    m.VisibleFraction = mean(double(history.Visible));
    m.StateChangeCount = stateChanges;
    metrics(end + 1) = m; %#ok<AGROW>
end
end

function events = computeLogEvents(log)
events = struct('Time', {}, 'TargetID', {}, 'Type', {}, 'Detail', {});

ids = getUniqueTargetIds(log);
for id = ids(:).'
    history = buildTargetHistoryFromLog(log, id);
    if numel(history.Time) < 2
        continue;
    end
    states = string(history.State);
    for k = 2:numel(states)
        if states(k) == states(k - 1)
            continue;
        end
        evt.Time = history.Time(k);
        evt.TargetID = id;
        evt.Type = "stateChange";
        evt.Detail = states(k - 1) + " -> " + states(k);
        events(end + 1) = evt; %#ok<AGROW>
    end
end
end

function dist = computeLogDistributions(log)
dist = struct();
dist.StateTime = struct('TargetID', {}, 'State', {}, 'Duration', {});

ids = getUniqueTargetIds(log);
for id = ids(:).'
    history = buildTargetHistoryFromLog(log, id);
    if numel(history.Time) < 2
        continue;
    end
    dt = diff(history.Time);
    states = string(history.State(1:end-1));
    uniqueStates = unique(states);
    for s = uniqueStates(:).'
        mask = states == s;
        entry.TargetID = id;
        entry.State = s;
        entry.Duration = sum(dt(mask));
        dist.StateTime(end + 1) = entry; %#ok<AGROW>
    end
end
end

function summary = buildLogAnalysisSummary(result, log, config)
summary = struct();
summary.Text = sprintf(['Simulation: %.1f s, %d frames, %d targets ' ...
    '(birds=%d, quads=%d, fw=%d, ground=%d).'], ...
    result.Statistics.Duration, result.Statistics.FrameCount, ...
    result.Statistics.TargetCount, result.Statistics.BirdCount, ...
    result.Statistics.QuadcopterCount, result.Statistics.FixedWingCount, ...
    result.Statistics.GroundVehicleCount);
summary.EventCount = numel(result.Events);
if isfield(config, 'debug') && isfield(config.debug, 'verbose') && config.debug.verbose
    fprintf('[%s] Analysis: %s\n', getProjectName(config), summary.Text);
end
end

function meta = getTargetMetaFromLog(log, targetId)
meta = struct('Type', "", 'Subtype', "");
for k = 1:numel(log.Frames)
    idx = find([log.Frames(k).Targets.ID] == targetId, 1);
    if ~isempty(idx)
        t = log.Frames(k).Targets(idx);
        meta.Type = string(t.Type);
        meta.Subtype = string(t.Subtype);
        return;
    end
end
end

function value = getField(s, name, defaultValue)
if isfield(s, name)
    value = s.(name);
else
    value = defaultValue;
end
end

function name = getProjectName(config)
if isfield(config, 'project') && isfield(config.project, 'name')
    name = config.project.name;
else
    name = 'BirdScenarioMVP';
end
end
