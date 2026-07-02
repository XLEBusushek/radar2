function climbRate = limitFixedWingClimbAngle(climbRate, horizontalSpeed, config)
% limitFixedWingClimbAngle - Clamp vertical speed by climb/descent angle and max Vz.
arguments
    climbRate (1, 1) double
    horizontalSpeed (1, 1) double {mustBeNonnegative}
    config (1, 1) struct
end

fw = config.fixedWing;
fl = fw.flightLevel;
maxClimbRate = horizontalSpeed * tan(deg2rad(fl.maxClimbAngleDeg));
maxDescentRate = horizontalSpeed * tan(deg2rad(fl.maxDescentAngleDeg));
maxClimbRate = min(maxClimbRate, fw.maxVerticalSpeed);
maxDescentRate = min(maxDescentRate, fw.maxVerticalSpeed);

climbRate = min(max(climbRate, -maxDescentRate), maxClimbRate);
end
