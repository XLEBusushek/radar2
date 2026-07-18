function targetOut = addFixedWing2OutputFields(targetOut, payload)
% addFixedWing2OutputFields - Поля телеметрии Fixed-wing2.
targetOut.RouteIndex = getPayloadField(payload, 'RouteIndex', nan);
targetOut.CurrentLegProgress = getPayloadField(payload, 'CurrentLegProgress', nan);
targetOut.CurrentHeading = getPayloadField(payload, 'CurrentHeading', nan);
targetOut.TargetHeading = getPayloadField(payload, 'TargetHeading', nan);
targetOut.HeadingErrorDeg = getPayloadField(payload, 'HeadingErrorDeg', nan);
targetOut.TurnRateCommandDeg = getPayloadField(payload, 'TurnRateCommandDeg', nan);
targetOut.CurrentSpeed = getPayloadField(payload, 'CurrentSpeed', nan);
targetOut.TargetSpeed = getPayloadField(payload, 'TargetSpeed', nan);
targetOut.BaseCruiseSpeed = getPayloadField(payload, 'BaseCruiseSpeed', nan);
targetOut.SpeedProfileEvent = string(getPayloadField(payload, 'SpeedProfileEvent', ""));
targetOut.CurrentFlightLevel = getPayloadField(payload, 'CurrentFlightLevel', nan);
targetOut.FlightLevel = getPayloadField(payload, 'FlightLevel', nan);
targetOut.TargetFlightLevel = getPayloadField(payload, 'TargetFlightLevel', nan);
targetOut.AltitudeError = getPayloadField(payload, 'AltitudeError', nan);
targetOut.DesiredClimbRate = getPayloadField(payload, 'DesiredClimbRate', nan);
targetOut.ClimbAngleDeg = getPayloadField(payload, 'ClimbAngleDeg', nan);
targetOut.AltitudeProfileEvent = string(getPayloadField(payload, 'AltitudeProfileEvent', ""));
targetOut.DistanceToBoundary = getPayloadField(payload, 'DistanceToBoundary', nan);
targetOut.InWarningZone = getPayloadField(payload, 'InWarningZone', false);
targetOut.InCriticalZone = getPayloadField(payload, 'InCriticalZone', false);
targetOut.BorderFollowing = getPayloadField(payload, 'BorderFollowing', false);
targetOut.LastFW2Event = string(getPayloadField(payload, 'LastFW2Event', ""));
targetOut.WaypointIndex = targetOut.RouteIndex;
targetOut.MissionComplete = getPayloadField(payload, 'RouteComplete', false);
targetOut.HomePosition = getPayloadField(payload, 'HomePoint', nan(3, 1));
end
