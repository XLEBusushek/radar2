function tf = shouldValidateEachStep(config)
% shouldValidateEachStep - Whether to validate targets after every update step.
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
