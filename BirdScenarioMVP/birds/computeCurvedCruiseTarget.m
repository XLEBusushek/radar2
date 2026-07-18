function curvePoint = computeCurvedCruiseTarget(bird, config)
% computeCurvedCruiseTarget - Вычислить промежуточную точку кривой для Cruise.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

cc = config.birds.curvedCruise;

if isfield(bird.Payload, 'ForceDirectToTarget') && bird.Payload.ForceDirectToTarget
  endPos = bird.Payload.CruiseTargetPosition(:);
  curvePoint = endPos;
  curvePoint(3) = min(max(curvePoint(3), cc.minCruiseAltitude), cc.maxCruiseAltitude);
  curvePoint = enforceWorldBounds(curvePoint, config.world.size);
  return;
end

startPos = bird.Payload.CruiseStartPosition(:);
endPos = bird.Payload.CruiseTargetPosition(:);
p = bird.Payload.CruiseProgress;
cruisePhase = bird.Payload.CruisePhase;

basePoint = startPos + p * (endPos - startPos);
sideOffset = bird.Payload.CruiseSideDirection(:) * ...
    bird.Payload.CruiseLateralOffset * sin(pi * p + cruisePhase);
verticalOffset = [0; 0; bird.Payload.CruiseVerticalOffset * sin(2 * pi * p + cruisePhase)];

curvePoint = basePoint + sideOffset + verticalOffset;
curvePoint(3) = min(max(curvePoint(3), cc.minCruiseAltitude), cc.maxCruiseAltitude);
curvePoint = enforceWorldBounds(curvePoint, config.world.size);
end
