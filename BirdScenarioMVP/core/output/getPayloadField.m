function value = getPayloadField(payload, fieldName, defaultValue)
% getPayloadField - Прочитать поле Payload с значением по умолчанию.
if isfield(payload, fieldName) && ~isempty(payload.(fieldName))
    value = payload.(fieldName);
    if strcmp(fieldName, 'DesiredVelocity')
        value = value(:);
    end
else
    value = defaultValue;
end
end
