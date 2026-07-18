function value = randIntRange(range)
% randIntRange - Равномерная выборка целого числа из включительного диапазона [range(1), range(2)].
arguments
    range (1, 2) double
end

lo = ceil(range(1));
hi = floor(range(2));
if hi < lo
    error('randIntRange:InvalidRange', 'range(2) must be >= range(1).');
end

value = randi([lo, hi]);
end
