function angle = fw2_wrapAngle(angle)
% fw2_wrapAngle - Привести угол к диапазону [-pi, pi].
angle = mod(angle + pi, 2 * pi) - pi;
end
