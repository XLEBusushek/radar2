function target = initializeQuadcopterReturn(target, config)
% initializeQuadcopterReturn - Задать цель возврата на домашнюю позицию.
safeAltitude = max(target.Payload.HomePosition(3) + 40, config.quadcopter.operatingAltitudeRange(1));
target.Payload.DesiredAltitude = max(target.Position(3), safeAltitude);
speed = config.quadcopter.transitSpeedRange(1) + ...
    rand() * (config.quadcopter.transitSpeedRange(2) - config.quadcopter.transitSpeedRange(1));
target.Payload.DesiredSpeed = speed;
end
