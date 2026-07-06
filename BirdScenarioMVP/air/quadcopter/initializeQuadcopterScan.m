function target = initializeQuadcopterScan(target, config)
% initializeQuadcopterScan - Initialize scan pattern parameters.
qc = config.quadcopter;
target.Payload.ScanCenter = target.Position;
target.Payload.ScanRadius = qc.scanRadiusRange(1) + ...
    rand() * (qc.scanRadiusRange(2) - qc.scanRadiusRange(1));
target.Payload.ScanStartTime = target.CurrentTime;
target.Payload.ScanDuration = qc.scanTimeRange(1) + ...
    rand() * (qc.scanTimeRange(2) - qc.scanTimeRange(1));
target.Payload.ScanAngle = 0;
if rand() < 0.5
    target.Payload.ScanDirection = -1;
else
    target.Payload.ScanDirection = 1;
end
speed = qc.scanSpeedRange(1) + rand() * (qc.scanSpeedRange(2) - qc.scanSpeedRange(1));
target.Payload.DesiredSpeed = speed;
target.Payload.DesiredAltitude = target.Payload.ScanCenter(3);
end
