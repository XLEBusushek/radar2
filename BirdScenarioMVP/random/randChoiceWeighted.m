function choice = randChoiceWeighted(values, weights)
% randChoiceWeighted - Выбор значения пропорционально неотрицательным весам.
arguments
    values
    weights (:, 1) double
end

numValues = numel(values);
if numValues == 0
    error('randChoiceWeighted:EmptyValues', 'values must not be empty.');
end
if numel(weights) ~= numValues
    error('randChoiceWeighted:SizeMismatch', 'weights must match values.');
end
if any(weights < 0) || any(isnan(weights)) || any(isinf(weights))
    error('randChoiceWeighted:InvalidWeights', 'weights must be finite and nonnegative.');
end

weights = weights(:);
if sum(weights) == 0
    idx = 1;
else
    cumulative = cumsum(weights / sum(weights));
    idx = find(rand() <= cumulative, 1, 'first');
    if isempty(idx)
        idx = numValues;
    end
end

if isstring(values)
    choice = values(idx);
elseif iscell(values)
    choice = values{idx};
else
    choice = values(idx);
end
end
