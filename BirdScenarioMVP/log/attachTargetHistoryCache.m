function log = attachTargetHistoryCache(log)
% attachTargetHistoryCache - Прикрепить кэш истории по целям к TrajectoryLog.
arguments
    log (1, 1) struct
end

if isfield(log, 'TargetHistoryCache') && isa(log.TargetHistoryCache, 'containers.Map')
    return;
end

log.TargetHistoryCache = buildTargetHistoryCache(log);
end
