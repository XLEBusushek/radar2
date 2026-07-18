function mode = getHistoryMode(config)
% getHistoryMode - Определяет режим записи истории цели.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'historyMode')
    mode = string(config.log.historyMode);
else
    mode = "full";
end

if mode ~= "full" && mode ~= "minimal" && mode ~= "off" && mode ~= "none"
    error('getHistoryMode:InvalidMode', ...
        'historyMode must be full, minimal, off, or none.');
end
end
