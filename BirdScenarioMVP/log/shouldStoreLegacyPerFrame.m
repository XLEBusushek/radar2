function tf = shouldStoreLegacyPerFrame(config)
% shouldStoreLegacyPerFrame - Вызывать ли collectOutput на каждом кадре лога.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'legacyPerFrame')
    tf = logical(config.log.legacyPerFrame);
else
    tf = false;
end
end
