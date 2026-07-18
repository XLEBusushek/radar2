function tf = shouldIncrementalCsv(config)
% shouldIncrementalCsv - Добавлять ли строки CSV во время симуляции.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'incrementalCsv')
    tf = logical(config.log.incrementalCsv);
else
    tf = false;
end
end
