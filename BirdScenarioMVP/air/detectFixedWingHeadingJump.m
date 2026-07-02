function jumpDeg = detectFixedWingHeadingJump(previousHeading, newHeading)
% detectFixedWingHeadingJump - Absolute heading change in degrees.
arguments
    previousHeading (1, 1) double
    newHeading (1, 1) double
end

if isempty(previousHeading) || isnan(previousHeading)
    jumpDeg = 0;
    return;
end

jumpDeg = abs(wrapToPiLocal(newHeading - previousHeading)) * 180 / pi;
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
