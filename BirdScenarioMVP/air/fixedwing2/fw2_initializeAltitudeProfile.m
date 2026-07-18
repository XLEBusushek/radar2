function target = fw2_initializeAltitudeProfile(target, config)
% fw2_initializeAltitudeProfile - Инициализировать поля профиля высоты при создании.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

ap = config.fixedWing2.altitudeProfile;
target.Payload.AltitudeProfileEnabled = ap.enabled;

levels = ap.levelRange(1):ap.levelSpacing:ap.levelRange(2);
target.Payload.FlightLevels = levels;

if ap.enabled
    [~, idx] = min(abs(levels - target.Position(3)));
    flightLevel = levels(idx);
else
    flightLevel = target.Position(3);
end

target.Payload.CurrentFlightLevel = flightLevel;
target.Payload.TargetFlightLevel = flightLevel;
target.Payload.FlightLevel = flightLevel;
target.Position(3) = flightLevel;
target.Payload.LastAltitudeChangeTime = target.CurrentTime;
interval = ap.levelChangeIntervalRange(1) + rand() * diff(ap.levelChangeIntervalRange);
target.Payload.NextAltitudeChangeTime = target.CurrentTime + interval;
target.Payload.AltitudeProfileEvent = "";
target.Payload.AltitudeError = 0;
target.Payload.DesiredClimbRate = 0;
target.Payload.ClimbAngleDeg = 0;
end
