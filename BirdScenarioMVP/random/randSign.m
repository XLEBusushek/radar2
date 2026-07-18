function s = randSign()
% randSign - Возврат -1 или +1 с равной вероятностью.
if rand() < 0.5
    s = -1;
else
    s = 1;
end
end
