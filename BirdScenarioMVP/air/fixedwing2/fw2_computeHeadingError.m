function errorDeg = fw2_computeHeadingError(currentHeading, targetHeading)
% fw2_computeHeadingError - Signed heading error in degrees.
errorRad = fw2_wrapAngle(targetHeading - currentHeading);
errorDeg = errorRad * 180 / pi;
end
