function value = getStructField(s, fieldName, defaultValue)
% getStructField - Read struct field with default.
if isfield(s, fieldName) && ~isempty(s.(fieldName))
    value = s.(fieldName);
else
    value = defaultValue;
end
end
