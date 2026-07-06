function target = initializeQuadcopterLanding(target, config)
% initializeQuadcopterLanding - Configure landing descent toward home.
qc = config.quadcopter;
speed = qc.landingSpeedRange(1) + rand() * (qc.landingSpeedRange(2) - qc.landingSpeedRange(1));
target.Payload.DesiredSpeed = speed;
target.Payload.DesiredAltitude = 0;
end
