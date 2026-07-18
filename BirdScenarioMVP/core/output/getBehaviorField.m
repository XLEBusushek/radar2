function value = getBehaviorField(behavior, fieldName, defaultValue)
% getBehaviorField - Прочитать поле поведения с значением по умолчанию.
if isfield(behavior, fieldName) && ~isempty(behavior.(fieldName))
    value = behavior.(fieldName);
else
    value = defaultValue;
end
end
