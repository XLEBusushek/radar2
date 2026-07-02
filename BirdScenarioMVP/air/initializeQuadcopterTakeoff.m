function target = initializeQuadcopterTakeoff(target, config)
% initializeQuadcopterTakeoff - Set takeoff altitude target on state entry.
qc = config.quadcopter;
altRange = qc.takeoffAltitudeRange;
target.Payload.TakeoffTargetAltitude = altRange(1) + rand() * (altRange(2) - altRange(1));
target.Payload.DesiredAltitude = target.Payload.TakeoffTargetAltitude;
speed = qc.transitSpeedRange(1) + rand() * (qc.transitSpeedRange(2) - qc.transitSpeedRange(1));
target.Payload.DesiredSpeed = min(speed, qc.maxVerticalSpeed);
target.Payload.DesiredVelocity = [0; 0; target.Payload.DesiredSpeed];
end
