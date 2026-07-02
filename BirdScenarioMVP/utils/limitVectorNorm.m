function vLimited = limitVectorNorm(v, maxNorm)
% limitVectorNorm - Clamp vector norm to maxNorm; leave zero vector unchanged.
v = v(:);
normV = norm(v);

if normV == 0 || normV <= maxNorm
    vLimited = v;
else
    vLimited = v * (maxNorm / normV);
end
end
