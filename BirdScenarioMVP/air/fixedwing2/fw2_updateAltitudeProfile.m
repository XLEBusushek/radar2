function target = fw2_updateAltitudeProfile(target, config, dt)
% fw2_updateAltitudeProfile - Редкие смены эшелона на соседних уровнях.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

ap = config.fixedWing2.altitudeProfile;

if ~ap.enabled
    return;
end

if target.CurrentTime >= target.Payload.NextAltitudeChangeTime
    if rand() < ap.levelChangeProbability
        levels = target.Payload.FlightLevels;
        [~, idx] = min(abs(levels - target.Payload.CurrentFlightLevel));
        step = randi([-ap.maxLevelStep, ap.maxLevelStep]);
        if step == 0
            step = 1;
            if rand() < 0.5
                step = -1;
            end
        end
        newIdx = min(max(idx + step, 1), numel(levels));
        target.Payload.TargetFlightLevel = levels(newIdx);
        target.Payload.LastAltitudeChangeTime = target.CurrentTime;
        target.Payload.AltitudeProfileEvent = "levelChange";
    end
    interval = ap.levelChangeIntervalRange(1) + rand() * diff(ap.levelChangeIntervalRange);
    target.Payload.NextAltitudeChangeTime = target.CurrentTime + interval;
elseif isfield(target.Payload, 'AltitudeProfileEvent') && ...
        string(target.Payload.AltitudeProfileEvent) == "levelChange"
    target.Payload.AltitudeProfileEvent = "";
end

if abs(target.Position(3) - target.Payload.TargetFlightLevel) < ap.altitudeTolerance
    target.Payload.CurrentFlightLevel = target.Payload.TargetFlightLevel;
end
target.Payload.FlightLevel = target.Payload.CurrentFlightLevel;
end
