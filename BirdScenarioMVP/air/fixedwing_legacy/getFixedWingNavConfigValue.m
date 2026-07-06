function value = getFixedWingNavConfigValue(config, navField, antiBounceField, defaultValue)
% getFixedWingNavConfigValue - Read navigation config with antiBounce fallback.
arguments
    config (1, 1) struct
    navField (1, :) char
    antiBounceField (1, :) char = ""
    defaultValue = []
end

value = defaultValue;
if isfield(config, 'fixedWing') && isfield(config.fixedWing, 'navigation') && ...
        isfield(config.fixedWing.navigation, navField)
    value = config.fixedWing.navigation.(navField);
elseif antiBounceField ~= "" && isfield(config, 'fixedWing') && ...
        isfield(config.fixedWing, 'antiBounce') && ...
        isfield(config.fixedWing.antiBounce, antiBounceField)
    value = config.fixedWing.antiBounce.(antiBounceField);
end
end
