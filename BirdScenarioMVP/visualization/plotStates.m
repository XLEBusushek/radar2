function fig = plotStates(trajectoryLog, config)
% plotStates - Временная шкала состояний FSM из TrajectoryLog.
arguments
    trajectoryLog (1, 1) struct
    config (1, 1) struct
end

if ~shouldPlot(config, 'showStates', 'stateFigure')
    fig = [];
    return;
end

fig = figure('Name', 'BirdScenario - States', 'NumberTitle', 'off', ...
    'Visible', analysisFigureVisibility(config));
ax = axes(fig);
hold(ax, 'on');
grid(ax, 'on');

ids = getUniqueTargetIds(trajectoryLog);
maxTargets = min(numel(ids), 12);
for i = 1:maxTargets
    id = ids(i);
    history = buildTargetHistoryFromLog(trajectoryLog, id);
    if isempty(history.Time)
        continue;
    end
    states = string(history.State(:));
    stateValues = arrayfun(@stateToNumeric, states);
    meta = getTargetMetaFromLog(trajectoryLog, id);
    label = sprintf('%s %d', meta.Type, id);
    plot(ax, history.Time, stateValues, '-', 'LineWidth', 1.2, 'DisplayName', label);
end

yticks(ax, [1:5, 10:14, 20:24, 30:35]);
yticklabels(ax, {'1 Perched', '2 Takeoff', '3 Cruise', '4 Landing', '5 Hidden', ...
    '10 Idle', '11 Transit', '12 Hover', '13 Scan', '14 Return', ...
    '20 Drive', '21 Stop', '22 Turn', '23 LeaveRoad', '24 ReturnRoad', ...
    '30 Climb', '31 Descend', '32 Loiter', '33 Dive', '34 Recover', '35 ExitArea'});
ylim(ax, [0.5, 35.5]);

xlabel(ax, 'Time (s)');
ylabel(ax, 'State');
title(ax, 'BirdScenario - FSM States');
if maxTargets <= 12
    legend(ax, 'Location', 'bestoutside');
end
hold(ax, 'off');

saveAnalysisFigure(fig, config.analysis.stateFile, config);
if ~keepFiguresOpen(config)
    close(fig);
end
end

function tf = shouldPlot(config, showField, legacyField)
analysis = config.analysis;
if isfield(analysis, showField)
    tf = analysis.(showField);
elseif isfield(analysis, legacyField)
    tf = analysis.(legacyField);
else
    tf = false;
end
end

function tf = keepFiguresOpen(config)
tf = isfield(config, 'analysis') && isfield(config.analysis, 'showFigures') && ...
    config.analysis.showFigures;
end

function meta = getTargetMetaFromLog(log, targetId)
meta = struct('Type', "");
for k = 1:numel(log.Frames)
    idx = find([log.Frames(k).Targets.ID] == targetId, 1);
    if ~isempty(idx)
        meta.Type = string(log.Frames(k).Targets(idx).Type);
        return;
    end
end
end
