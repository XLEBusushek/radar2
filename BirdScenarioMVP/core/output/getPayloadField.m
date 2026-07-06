function value = getPayloadField(payload, fieldName, defaultValue)
% getPayloadField - Read payload field with default.
if isfield(payload, fieldName) && ~isempty(payload.(fieldName))
    value = payload.(fieldName);
    if strcmp(fieldName, 'DesiredVelocity')
        value = value(:);
    end
else
    value = defaultValue;
end
end
