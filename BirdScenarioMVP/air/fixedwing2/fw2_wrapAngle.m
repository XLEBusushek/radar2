function angle = fw2_wrapAngle(angle)
% fw2_wrapAngle - Wrap angle to [-pi, pi].
angle = mod(angle + pi, 2 * pi) - pi;
end
