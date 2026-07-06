function report = detectFixedWingNavigationAnomaly(target, config)
% detectFixedWingNavigationAnomaly - Detect suspicious fixed-wing navigation patterns.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

report = struct('Anomalies', emptyAnomalyList(), 'Summary', struct());
report.Summary.headingChurn = 0;
report.Summary.waypointOscillation = 0;
report.Summary.smallLoop = 0;
report.Summary.stationaryHover = 0;
report.Summary.recoveryToggle = 0;
report.Summary.loiterToggle = 0;
report.Summary.noWaypointProgress = 0;

if ~isfield(target, 'History') || ~isfield(target.History, 'Time') || ...
        numel(target.History.Time) < 3
    return;
end

history = target.History;
times = history.Time(:);
dt = median(diff(times));
if isnan(dt) || dt <= 0
    dt = 1;
end

diag = getDiagnosticsConfig(config);
anomalies = emptyAnomalyList();

anomalies = [anomalies, detectHeadingChurn(history, times, dt, diag)]; %#ok<AGROW>
anomalies = [anomalies, detectWaypointOscillation(history, times, diag)]; %#ok<AGROW>
anomalies = [anomalies, detectSmallLoops(history, times, dt, diag)]; %#ok<AGROW>
anomalies = [anomalies, detectStationaryHover(history, times, diag)]; %#ok<AGROW>
anomalies = [anomalies, detectFlagToggle(history, times, 'BoundaryRecoveryActive', ...
    'recoveryToggle', diag.toggleWindow, diag.toggleThreshold)]; %#ok<AGROW>
anomalies = [anomalies, detectFlagToggle(history, times, 'LoiterActive', ...
    'loiterToggle', diag.toggleWindow, diag.toggleThreshold)]; %#ok<AGROW>
anomalies = [anomalies, detectNoWaypointProgress(history, times, diag)]; %#ok<AGROW>

report.Anomalies = anomalies;
report.Summary = summarizeAnomalies(anomalies);
end

function diag = getDiagnosticsConfig(config)
diag.headingErrorJumpDeg = 20;
diag.headingChurnWindow = 30;
diag.waypointChangeWindow = 60;
diag.loopRadius = 90;
diag.loopMinDuration = 15;
diag.noProgressWindow = 30;
diag.toggleWindow = 120;
diag.headingSignFlipThreshold = 5;
diag.waypointChangeThreshold = 3;
diag.toggleThreshold = 2;
diag.stationaryDisplacement = 80;
diag.stationaryWindow = 25;

if isfield(config, 'fixedWing') && isfield(config.fixedWing, 'diagnostics')
    d = config.fixedWing.diagnostics;
    fields = fieldnames(diag);
    for k = 1:numel(fields)
        if isfield(d, fields{k})
            diag.(fields{k}) = d.(fields{k});
        end
    end
end
end

function anomalies = detectHeadingChurn(history, times, dt, diag)
anomalies = emptyAnomalyList();
if ~isfield(history, 'HeadingErrorDeg')
    return;
end

errors = history.HeadingErrorDeg(:);
signFlips = diff(sign(errors)) ~= 0;
windowSteps = max(2, round(diag.headingChurnWindow / dt));
flipThreshold = diag.headingSignFlipThreshold;

startIdx = 1;
for k = 2:numel(errors)
    jump = abs(errors(k) - errors(k - 1));
    if jump >= diag.headingErrorJumpDeg
        anomalies(end + 1) = makeAnomaly('headingChurn', times(k - 1), times(k), ...
            sprintf('Heading error jump %.1f deg at t=%.1f s.', jump, times(k)), ...
            struct('JumpDeg', jump)); %#ok<AGROW>
    end

    if k >= windowSteps
        windowFlips = sum(signFlips((k - windowSteps + 1):(k - 1)));
        if windowFlips >= flipThreshold && k == startIdx + windowSteps - 1
            anomalies(end + 1) = makeAnomaly('headingChurn', times(k - windowSteps + 1), times(k), ...
                sprintf('Frequent heading error sign changes (%d) over %.0f s.', ...
                windowFlips, diag.headingChurnWindow), ...
                struct('SignFlips', windowFlips)); %#ok<AGROW>
            startIdx = k;
        end
    end
end
end

function anomalies = detectWaypointOscillation(history, times, diag)
anomalies = emptyAnomalyList();
fieldName = 'CurrentWaypointIndex';
if ~isfield(history, fieldName)
    fieldName = 'WaypointIndex';
end
if ~isfield(history, fieldName)
    return;
end

indices = history.(fieldName)(:);
changes = find(diff(indices) ~= 0);
if numel(changes) < 2
    return;
end

window = diag.waypointChangeWindow;
threshold = diag.waypointChangeThreshold;
for k = 1:numel(changes)
    tStart = times(changes(k));
    tEnd = tStart + window;
    count = sum(times(changes) >= tStart & times(changes) <= tEnd);
    if count > threshold
        anomalies(end + 1) = makeAnomaly('waypointOscillation', tStart, tEnd, ...
            sprintf('%d waypoint index changes within %.0f s.', count, window), ...
            struct('ChangeCount', count)); %#ok<AGROW>
    end
end
end

function anomalies = detectSmallLoops(history, times, dt, diag)
anomalies = emptyAnomalyList();
if ~isfield(history, 'Position')
    return;
end

positions = history.Position(:, 1:2);
windowSteps = max(3, round(diag.loopMinDuration / dt));
radius = diag.loopRadius;

for k = 1:(size(positions, 1) - windowSteps)
    segment = positions(k:(k + windowSteps), :);
    center = mean(segment, 1);
    if all(vecnorm(segment - center, 2, 2) <= radius)
        anomalies(end + 1) = makeAnomaly('smallLoop', times(k), times(k + windowSteps), ...
            sprintf('Local loop radius <= %.0f m for %.0f s.', radius, times(k + windowSteps) - times(k)), ...
            struct('Radius', radius, 'Duration', times(k + windowSteps) - times(k))); %#ok<AGROW>
        k = k + windowSteps;
    end
end
end

function anomalies = detectStationaryHover(history, times, diag)
anomalies = emptyAnomalyList();
if ~isfield(history, 'Position')
    return;
end

positions = history.Position(:, 1:2);
window = diag.stationaryWindow;
maxDisp = diag.stationaryDisplacement;

for k = 2:numel(times)
    tStart = times(k) - window;
    idx = find(times >= tStart & times <= times(k));
    if numel(idx) < 2
        continue;
    end
    segment = positions(idx, :);
    displacement = norm(segment(end, :) - segment(1, :));
    if displacement <= maxDisp && (times(k) - times(idx(1))) >= window * 0.9
        anomalies(end + 1) = makeAnomaly('stationaryHover', times(idx(1)), times(k), ...
            sprintf('Displacement %.1f m over %.0f s near one point.', displacement, window), ...
            struct('Displacement', displacement)); %#ok<AGROW>
    end
end
end

function anomalies = detectFlagToggle(history, times, fieldName, anomalyType, window, threshold)
anomalies = emptyAnomalyList();
if ~isfield(history, fieldName)
    return;
end

flags = logical(history.(fieldName)(:));
edges = find(diff([false; flags]) == 1);
if numel(edges) < threshold + 1
    return;
end

for k = 1:numel(edges)
    tStart = times(edges(k));
    tEnd = tStart + window;
    count = sum(times(edges) >= tStart & times(edges) <= tEnd);
    if count > threshold
        anomalies(end + 1) = makeAnomaly(anomalyType, tStart, tEnd, ...
            sprintf('%s toggled %d times within %.0f s.', fieldName, count, window), ...
            struct('ToggleCount', count)); %#ok<AGROW>
    end
end
end

function anomalies = detectNoWaypointProgress(history, times, diag)
anomalies = emptyAnomalyList();
if ~isfield(history, 'DistanceToWaypoint') || ~isfield(history, 'State')
    return;
end

distances = history.DistanceToWaypoint(:);
states = string(history.State(:));
window = diag.noProgressWindow;

for k = 2:numel(times)
    if ~ismember(states(k), ["Cruise", "Turn"])
        continue;
    end
    tStart = times(k) - window;
    idx = find(times >= tStart & times <= times(k));
    if numel(idx) < 3
        continue;
    end
    if all(states(idx) == "Cruise" | states(idx) == "Turn") && ...
            distances(k) >= min(distances(idx)) - 5
        anomalies(end + 1) = makeAnomaly('noWaypointProgress', times(idx(1)), times(k), ...
            sprintf('No progress toward waypoint over %.0f s (dist %.0f m).', ...
            window, distances(k)), ...
            struct('Distance', distances(k))); %#ok<AGROW>
    end
end
end

function anomaly = makeAnomaly(type, startTime, endTime, description, metrics)
anomaly = struct( ...
    'Type', string(type), ...
    'StartTime', startTime, ...
    'EndTime', endTime, ...
    'Description', string(description), ...
    'Metrics', metrics);
end

function anomalies = emptyAnomalyList()
anomalies = struct('Type', {}, 'StartTime', {}, 'EndTime', {}, ...
    'Description', {}, 'Metrics', {});
end

function summary = summarizeAnomalies(anomalies)
summary = struct('headingChurn', 0, 'waypointOscillation', 0, 'smallLoop', 0, ...
    'stationaryHover', 0, 'recoveryToggle', 0, 'loiterToggle', 0, ...
    'noWaypointProgress', 0);
if isempty(anomalies)
    return;
end
types = string({anomalies.Type});
uniqueTypes = unique(types);
for k = 1:numel(uniqueTypes)
    summary.(char(uniqueTypes(k))) = sum(types == uniqueTypes(k));
end
end
