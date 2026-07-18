function target = initializeFixedWingFlightLevel(target, config)
% initializeFixedWingFlightLevel - Привязать fixed-wing UAV к ближайшему эшелону.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

fl = config.fixedWing.flightLevel;
levels = fl.levelRange(1):fl.levelSpacing:fl.levelRange(2);
if isempty(levels)
    levels = target.Position(3);
end

[~, idx] = min(abs(levels - target.Position(3)));
level = levels(idx);
tolerance = fl.altitudeTolerance;

target.Payload.FlightLevel = level;
target.Payload.TargetFlightLevel = level;
target.Payload.FlightLevelIndex = idx;
target.Payload.AltitudeBand = [level - tolerance, level + tolerance];
target.Payload.DesiredAltitude = level;
target.Payload.SmoothedDesiredAltitude = level;
target.Payload.AltitudeError = level - target.Position(3);
target.Payload.DesiredClimbRate = 0;
target.Payload.ClimbAngleDeg = 0;
end
