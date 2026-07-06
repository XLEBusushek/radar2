function heading = computeExitHeading(position, exitPoint)
% computeExitHeading - Compute stable heading toward the mission exit point.
arguments
    position (3, 1) double
    exitPoint (3, 1) double
end

delta = exitPoint(1:2) - position(1:2);
if norm(delta) < 1e-6
    heading = 0;
else
    heading = atan2(delta(2), delta(1));
end
end
