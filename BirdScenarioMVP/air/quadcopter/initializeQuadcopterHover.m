function target = initializeQuadcopterHover(target, config)
% initializeQuadcopterHover - Настроить якорь и длительность зависания.
qc = config.quadcopter;
target.Payload.HoverAnchor = target.Position;
target.Payload.HoverDuration = qc.hoverTimeRange(1) + ...
    rand() * (qc.hoverTimeRange(2) - qc.hoverTimeRange(1));
target.Payload.DesiredVelocity = zeros(3, 1);
target.Payload.DesiredSpeed = 0;
target.Payload.DesiredAltitude = target.Position(3);
end
