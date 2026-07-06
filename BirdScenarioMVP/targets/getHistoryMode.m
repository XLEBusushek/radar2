function mode = getHistoryMode(config)
% getHistoryMode - Resolve target history recording mode.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'historyMode')
    mode = string(config.log.historyMode);
else
    mode = "full";
end

if mode ~= "full" && mode ~= "minimal" && mode ~= "off"
    error('getHistoryMode:InvalidMode', 'historyMode must be full, minimal, or off.');
end
end
