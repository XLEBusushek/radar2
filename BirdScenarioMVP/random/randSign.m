function s = randSign()
% randSign - Return either -1 or +1 with equal probability.
if rand() < 0.5
    s = -1;
else
    s = 1;
end
end
