function target = applyFixedWingAltitudeSmoothing(target, config)
% applyFixedWingAltitudeSmoothing - Сгладить желаемую высоту к целевому эшелону.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

alpha = config.fixedWing.motion.altitudeSmoothing;
if ~isfield(target.Payload, 'SmoothedDesiredAltitude') || ...
        isempty(target.Payload.SmoothedDesiredAltitude)
    target.Payload.SmoothedDesiredAltitude = target.Position(3);
end

targetAltitude = target.Payload.TargetFlightLevel;
target.Payload.SmoothedDesiredAltitude = target.Payload.SmoothedDesiredAltitude + ...
    alpha * (targetAltitude - target.Payload.SmoothedDesiredAltitude);
target.Payload.DesiredAltitude = target.Payload.SmoothedDesiredAltitude;
end
