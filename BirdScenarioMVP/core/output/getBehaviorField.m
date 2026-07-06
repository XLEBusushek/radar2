function value = getBehaviorField(behavior, fieldName, defaultValue)
% getBehaviorField - Read behavior field with default.
if isfield(behavior, fieldName) && ~isempty(behavior.(fieldName))
    value = behavior.(fieldName);
else
    value = defaultValue;
end
end
