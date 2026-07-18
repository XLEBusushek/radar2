function target = initializeQuadcopterLanding(target, config)
% initializeQuadcopterLanding - Настроить снижение при посадке к дому.
qc = config.quadcopter;
speed = qc.landingSpeedRange(1) + rand() * (qc.landingSpeedRange(2) - qc.landingSpeedRange(1));
target.Payload.DesiredSpeed = speed;
target.Payload.DesiredAltitude = 0;
end
