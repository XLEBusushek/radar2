function fig = plotFixedWingNavigationDebug(scenario, config, targetId)
% plotFixedWingNavigationDebug - XY and time-series navigation debug plot.
arguments
    scenario (1, 1) struct
    config (1, 1) struct
    targetId (1, 1) double = nan
end

fixedWingUAVs = getScenarioFixedWingUAVs(scenario);
if isempty(fixedWingUAVs)
    fig = figure('Name', 'Fixed-Wing Navigation Debug', 'NumberTitle', 'off', ...
        'Visible', analysisFigureVisibility(config));
    return;
end

if isnan(targetId)
    targets = fixedWingUAVs;
else
    ids = arrayfun(@(t) t.ID, fixedWingUAVs);
    idx = find(ids == targetId, 1);
    if isempty(idx)
        targets = fixedWingUAVs(1);
    else
        targets = fixedWingUAVs(idx);
    end
end

fig = figure('Name', 'Fixed-Wing Navigation Debug', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));

for plotIdx = 1:numel(targets)
    target = targets(plotIdx);
    if numel(targets) > 1
        figure(fig);
        subplot(1, numel(targets), plotIdx);
    else
        tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
    end
    plotTargetNavigationDebug(target, config, fig, plotIdx, numel(targets));
end
end

function plotTargetNavigationDebug(target, config, fig, plotIdx, numTargets)
history = target.History;
times = history.Time(:);
positions = history.Position(:, 1:2);

if numTargets > 1
    axXY = gca;
else
    axXY = nexttile(1);
end
hold(axXY, 'on');
grid(axXY, 'on');
axis(axXY, 'equal');

plotBoundaryMargin(axXY, config);
plotStateColoredTrajectory(axXY, positions, string(history.State(:)), history);
plotMissionWaypoints(axXY, target);
plotLookaheadTrail(axXY, history);
plotAntiBounceMarkers(axXY, history, positions);
plotCornerAndBoundaryMarkers(axXY, history, positions);
plotSmoothedNavTrail(axXY, history);
plotWaypointSwitchMarkers(axXY, history, positions);
plotHeadingArrows(axXY, positions, history);
plotHeadingErrorSpikes(axXY, history, positions, config);

xlabel(axXY, 'X (m)');
ylabel(axXY, 'Y (m)');
title(axXY, sprintf('Fixed-Wing %d Navigation (XY)', target.ID));
hold(axXY, 'off');

if numTargets > 1
    return;
end

axErr = nexttile(2);
plot(axErr, times, history.HeadingErrorDeg, 'LineWidth', 1.2);
grid(axErr, 'on');
ylabel(axErr, 'Heading error (deg)');
title(axErr, 'Heading Error');

axDist = nexttile(3);
plot(axDist, times, history.DistanceToWaypoint, 'LineWidth', 1.2);
grid(axDist, 'on');
ylabel(axDist, 'Distance (m)');
xlabel(axDist, 'Time (s)');
title(axDist, 'Distance To Waypoint');

axFlags = nexttile(4);
hold(axFlags, 'on');
plot(axFlags, times, double(history.BoundaryRecoveryActive), 'LineWidth', 1.2, ...
    'DisplayName', 'BoundaryRecovery');
plot(axFlags, times, double(history.LoiterActive) + 0.05, 'LineWidth', 1.2, ...
    'DisplayName', 'Loiter');
plot(axFlags, times, double(history.FinalPhaseStarted) + 0.10, 'LineWidth', 1.2, ...
    'DisplayName', 'FinalPhase');
if isfield(history, 'AntiBounceActive')
    plot(axFlags, times, double(history.AntiBounceActive) + 0.15, 'LineWidth', 1.2, ...
        'DisplayName', 'AntiBounce');
end
grid(axFlags, 'on');
ylim(axFlags, [-0.1, 1.3]);
ylabel(axFlags, 'Active');
xlabel(axFlags, 'Time (s)');
title(axFlags, 'Recovery / Loiter / Final Phase');
legend(axFlags, 'Location', 'best');
hold(axFlags, 'off');

if isfield(config, 'world') && isfield(config.world, 'size')
    xlim(axXY, [0, config.world.size(1)]);
    ylim(axXY, [0, config.world.size(2)]);
end
end

function plotBoundaryMargin(ax, config)
if ~isfield(config, 'fixedWing') || ~isfield(config.fixedWing, 'boundary') || ...
        ~config.fixedWing.boundary.enabled || ~isfield(config, 'world')
    return;
end
margin = config.fixedWing.boundary.margin;
worldX = config.world.size(1);
worldY = config.world.size(2);
bx = [margin, worldX - margin, worldX - margin, margin, margin];
by = [margin, margin, worldY - margin, worldY - margin, margin];
plot(ax, bx, by, '--', 'Color', [0.5, 0.5, 0.5], 'LineWidth', 1, ...
    'DisplayName', 'Boundary margin');
end

function plotStateColoredTrajectory(ax, positions, states, history)
stateColors = containers.Map( ...
    {'Cruise', 'Turn', 'Loiter', 'Return', 'BoundaryRecovery', 'Dive', 'Recover', ...
    'Climb', 'Descend', 'ApproachExit', 'AlignExit', 'Exit', 'LoiterEnd', 'ReturnHome'}, ...
    {[0.2, 0.4, 0.9], [0.9, 0.5, 0.1], [0.6, 0.2, 0.8], [0.1, 0.7, 0.3], ...
    [0.9, 0.2, 0.2], [0.5, 0.5, 0.9], [0.4, 0.7, 0.9], [0.3, 0.6, 0.6], ...
    [0.5, 0.6, 0.3], [0.8, 0.3, 0.3], [0.7, 0.2, 0.5], [0.4, 0.2, 0.2], ...
    [0.7, 0.5, 0.9], [0.2, 0.6, 0.4]});

recoveryActive = false(size(states));
if isfield(history, 'BoundaryRecoveryActive')
    recoveryActive = logical(history.BoundaryRecoveryActive(:));
end

for k = 2:size(positions, 1)
    if recoveryActive(k)
        state = 'BoundaryRecovery';
    else
        state = char(states(k));
    end
    if isKey(stateColors, state)
        color = stateColors(state);
    else
        color = [0.4, 0.4, 0.4];
    end
    plot(ax, positions((k - 1):k, 1), positions((k - 1):k, 2), '-', ...
        'Color', color, 'LineWidth', 1.5, 'HandleVisibility', 'off');
end
end

function plotMissionWaypoints(ax, target)
if ~isfield(target, 'Payload') || ~isfield(target.Payload, 'Waypoints')
    return;
end
wps = target.Payload.Waypoints;
plot(ax, wps(:, 1), wps(:, 2), 'kp', 'MarkerSize', 8, 'MarkerFaceColor', [1, 0.9, 0.2], ...
    'DisplayName', 'Mission waypoints');
for i = 1:size(wps, 1)
    text(ax, wps(i, 1), wps(i, 2), sprintf(' %d', i), 'FontSize', 8, 'Color', [0.2, 0.2, 0.2]);
end
end

function plotLookaheadTrail(ax, history)
if isfield(history, 'SmoothedLookaheadPoint') && size(history.SmoothedLookaheadPoint, 2) >= 2
    look = history.SmoothedLookaheadPoint;
    plot(ax, look(:, 1), look(:, 2), '-', 'Color', [0.2, 0.6, 0.3], ...
        'LineWidth', 0.9, 'DisplayName', 'Smoothed lookahead');
end
if isfield(history, 'RawLookaheadPoint') && size(history.RawLookaheadPoint, 2) >= 2
    raw = history.RawLookaheadPoint;
    plot(ax, raw(:, 1), raw(:, 2), ':', 'Color', [0.8, 0.4, 0.2], ...
        'LineWidth', 0.7, 'DisplayName', 'Raw lookahead');
elseif isfield(history, 'LookaheadPoint')
    look = history.LookaheadPoint;
    if size(look, 2) >= 2
        plot(ax, look(:, 1), look(:, 2), ':', 'Color', [0.6, 0.6, 0.6], ...
            'LineWidth', 0.8, 'DisplayName', 'Lookahead trail');
    end
end
end

function plotSmoothedNavTrail(ax, history)
if ~isfield(history, 'SmoothedNavigationTarget') || size(history.SmoothedNavigationTarget, 2) < 2
    return;
end
nav = history.SmoothedNavigationTarget;
plot(ax, nav(:, 1), nav(:, 2), '--', 'Color', [0.3, 0.3, 0.8], ...
    'LineWidth', 0.8, 'DisplayName', 'Smoothed nav target');
end

function plotAntiBounceMarkers(ax, history, positions)
if ~isfield(history, 'AntiBounceActive')
    return;
end
active = logical(history.AntiBounceActive(:));
idx = find(active);
if isempty(idx)
    return;
end
plot(ax, positions(idx, 1), positions(idx, 2), 'rx', 'MarkerSize', 5, ...
    'DisplayName', 'AntiBounce active');
end

function plotCornerAndBoundaryMarkers(ax, history, positions)
idx = [];
if isfield(history, 'LastBoundaryEvent')
    events = string(history.LastBoundaryEvent(:));
    idx = [idx; find(events == "boundaryVelocitySmoothed")]; %#ok<AGROW>
end
if isfield(history, 'CornerCuttingActive')
    idx = [idx; find(logical(history.CornerCuttingActive(:)))]; %#ok<AGROW>
end
idx = unique(idx);
if isempty(idx)
    return;
end
plot(ax, positions(idx, 1), positions(idx, 2), 'c.', 'MarkerSize', 10, ...
    'DisplayName', 'Corner / boundary smooth');
end

function plotWaypointSwitchMarkers(ax, history, positions)
fieldName = 'CurrentWaypointIndex';
if ~isfield(history, fieldName)
    fieldName = 'WaypointIndex';
end
if ~isfield(history, fieldName)
    return;
end
idx = history.(fieldName)(:);
changes = find(diff(idx) ~= 0);
if isempty(changes)
    return;
end
plot(ax, positions(changes + 1, 1), positions(changes + 1, 2), 'mo', ...
    'MarkerSize', 6, 'MarkerFaceColor', 'm', 'DisplayName', 'Waypoint switch');
end

function plotHeadingArrows(ax, positions, history)
if ~isfield(history, 'CurrentHeading')
    return;
end
n = size(positions, 1);
step = max(1, floor(n / 25));
headings = history.CurrentHeading(:);
arrowLen = 40;
for k = 1:step:n
    dx = arrowLen * cos(headings(k));
    dy = arrowLen * sin(headings(k));
    quiver(ax, positions(k, 1), positions(k, 2), dx, dy, 0, ...
        'Color', [0.1, 0.1, 0.1], 'MaxHeadSize', 0.8, 'HandleVisibility', 'off');
end
end

function plotHeadingErrorSpikes(ax, history, positions, config)
if ~isfield(history, 'HeadingErrorDeg')
    return;
end
threshold = 20;
if isfield(config, 'fixedWing') && isfield(config.fixedWing, 'antiBounce') && ...
        isfield(config.fixedWing.antiBounce, 'maxHeadingJumpDeg')
    threshold = config.fixedWing.antiBounce.maxHeadingJumpDeg + 2;
elseif isfield(config, 'fixedWing') && isfield(config.fixedWing, 'diagnostics') && ...
        isfield(config.fixedWing.diagnostics, 'headingErrorJumpDeg')
    threshold = config.fixedWing.diagnostics.headingErrorJumpDeg;
end
if isfield(history, 'HeadingJumpDeg')
    spikes = find(history.HeadingJumpDeg(:) >= threshold);
else
    errors = history.HeadingErrorDeg(:);
    spikes = find(abs(diff(errors)) >= threshold);
end
if isempty(spikes)
    return;
end
plot(ax, positions(spikes + 1, 1), positions(spikes + 1, 2), 'rx', ...
    'MarkerSize', 8, 'LineWidth', 1.5, 'DisplayName', 'Heading error jump');
end
