function target = appendTargetHistory(target, config)
% appendTargetHistory - Append target history according to config.log.historyMode.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

switch getHistoryMode(config)
    case "none"
        return;
    case "off"
        target = appendTargetHistoryCore(target);
    case "minimal"
        target = appendTargetHistoryMinimal(target);
    otherwise
        target = appendTargetHistoryFull(target);
end
end
