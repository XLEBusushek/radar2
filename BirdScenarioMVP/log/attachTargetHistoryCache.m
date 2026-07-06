function log = attachTargetHistoryCache(log)
% attachTargetHistoryCache - Attach per-target history cache to TrajectoryLog.
arguments
    log (1, 1) struct
end

if isfield(log, 'TargetHistoryCache') && isa(log.TargetHistoryCache, 'containers.Map')
    return;
end

log.TargetHistoryCache = buildTargetHistoryCache(log);
end
