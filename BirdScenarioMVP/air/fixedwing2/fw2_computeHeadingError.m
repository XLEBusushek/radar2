function errorDeg = fw2_computeHeadingError(currentHeading, targetHeading)
% fw2_computeHeadingError - Знаковая ошибка курса в градусах.
errorRad = fw2_wrapAngle(targetHeading - currentHeading);
errorDeg = errorRad * 180 / pi;
end
