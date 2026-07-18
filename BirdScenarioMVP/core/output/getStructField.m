function value = getStructField(s, fieldName, defaultValue)
% getStructField - Прочитать поле структуры с значением по умолчанию.
if isfield(s, fieldName) && ~isempty(s.(fieldName))
    value = s.(fieldName);
else
    value = defaultValue;
end
end
