function plotLogSeries(ax, trajectoryLog, className, subtype, style, color, seriesFn)
% plotLogSeries - Plot time series for targets matching class/subtype.
ids = getUniqueTargetIds(trajectoryLog, className, subtype);
for id = ids(:).'
    history = buildTargetHistoryFromLog(trajectoryLog, id);
    if isempty(history.Time)
        continue;
    end
    y = seriesFn(history);
    plot(ax, history.Time, y, style, 'Color', color, 'LineWidth', 1.2);
end
end
