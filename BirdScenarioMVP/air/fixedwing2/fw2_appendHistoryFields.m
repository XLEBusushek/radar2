function history = fw2_appendHistoryFields(history, target)
% fw2_appendHistoryFields - Append fixed-wing2 telemetry to history.
p = target.Payload;
history = appendScalar(history, 'RouteIndex', p.RouteIndex);
history = appendScalar(history, 'CurrentLegProgress', p.CurrentLegProgress);
history = appendScalar(history, 'CurrentHeading', p.CurrentHeading);
history = appendScalar(history, 'TargetHeading', p.TargetHeading);
history = appendScalar(history, 'HeadingErrorDeg', p.HeadingErrorDeg);
history = appendScalar(history, 'TurnRateCommandDeg', p.TurnRateCommandDeg);
history = appendScalar(history, 'BaseCruiseSpeed', p.BaseCruiseSpeed);
history = appendScalar(history, 'CurrentSpeed', p.CurrentSpeed);
history = appendScalar(history, 'TargetSpeed', p.TargetSpeed);
history = appendScalar(history, 'SpeedProfileEvent', string(p.SpeedProfileEvent));
history = appendScalar(history, 'CurrentFlightLevel', p.CurrentFlightLevel);
history = appendScalar(history, 'FlightLevel', p.FlightLevel);
history = appendScalar(history, 'TargetFlightLevel', p.TargetFlightLevel);
history = appendScalar(history, 'AltitudeError', p.AltitudeError);
history = appendScalar(history, 'DesiredClimbRate', p.DesiredClimbRate);
history = appendScalar(history, 'ClimbAngleDeg', p.ClimbAngleDeg);
history = appendScalar(history, 'AltitudeProfileEvent', string(p.AltitudeProfileEvent));
history = appendScalar(history, 'DistanceToBoundary', p.DistanceToBoundary);
history = appendScalar(history, 'InWarningZone', logical(p.InWarningZone));
history = appendScalar(history, 'InCriticalZone', logical(p.InCriticalZone));
history = appendScalar(history, 'BorderFollowing', logical(p.BorderFollowing));
history = appendScalar(history, 'BorderFollowingTime', p.BorderFollowingTime);
history = appendScalar(history, 'LastFW2Event', string(p.LastFW2Event));
end

function history = appendScalar(history, fieldName, value)
if ~isfield(history, fieldName) || isempty(history.(fieldName))
    history.(fieldName) = value;
else
    history.(fieldName)(end + 1, 1) = value;
end
end
