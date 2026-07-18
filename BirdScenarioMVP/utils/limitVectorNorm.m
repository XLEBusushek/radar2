function vLimited = limitVectorNorm(v, maxNorm)
% limitVectorNorm - Ограничение нормы вектора до maxNorm; нулевой вектор не изменяется.
v = v(:);
normV = norm(v);

if normV == 0 || normV <= maxNorm
    vLimited = v;
else
    vLimited = v * (maxNorm / normV);
end
end
