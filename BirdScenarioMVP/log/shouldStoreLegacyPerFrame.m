function tf = shouldStoreLegacyPerFrame(config)
% shouldStoreLegacyPerFrame - Whether to call collectOutput on every log frame.
arguments
    config (1, 1) struct
end

if isfield(config, 'log') && isfield(config.log, 'legacyPerFrame')
    tf = logical(config.log.legacyPerFrame);
else
    tf = false;
end
end
