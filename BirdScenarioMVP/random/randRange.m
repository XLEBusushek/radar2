function value = randRange(range)
% randRange - Sample a scalar uniformly from [range(1), range(2)].
arguments
    range (1, 2) double
end

if range(2) < range(1)
    error('randRange:InvalidRange', 'range(2) must be >= range(1).');
end

value = range(1) + rand() * (range(2) - range(1));
end
