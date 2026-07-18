function turnSeverity = computeTurnSeverity(currentHeading, targetHeading)
% computeTurnSeverity - Вернуть нормализованную потребность в развороте в [0, 1].
arguments
    currentHeading (1, 1) double
    targetHeading (1, 1) double
end

headingError = abs(wrapToPiLocal(targetHeading - currentHeading));
turnSeverity = min(max(headingError / pi, 0), 1);
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
