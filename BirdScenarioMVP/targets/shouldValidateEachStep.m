function tf = shouldValidateEachStep(config)
% shouldValidateEachStep - Нужно ли проверять цели после каждого шага обновления.
arguments
    config (1, 1) struct
end

if isfield(config, 'validation') && isfield(config.validation, 'eachStep')
    tf = logical(config.validation.eachStep);
    return;
end

if isfield(config, 'debug') && isfield(config.debug, 'validateEachStep')
    tf = logical(config.debug.validateEachStep);
else
    tf = true;
end
end
