function bird = updateCruiseCurve(bird, config)
% updateCruiseCurve - Обновить прогресс кривой и промежуточную точку на каждом шаге.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

if isempty(bird.Payload.CruiseStartPosition) || isempty(bird.Payload.CruiseTargetPosition)
    return;
end

if isfield(bird.Payload, 'ForceDirectToTarget') && bird.Payload.ForceDirectToTarget
    bird.Payload.CurveWaypoint = bird.Payload.CruiseTargetPosition(:);
    return;
end

startPos = bird.Payload.CruiseStartPosition(:);
endPos = bird.Payload.CruiseTargetPosition(:);
totalDistance = norm(endPos(1:2) - startPos(1:2));

if totalDistance > 0
    currentDistance = norm(bird.Position(1:2) - startPos(1:2));
    bird.Payload.CruiseProgress = min(max(currentDistance / totalDistance, 0), 1);
else
    bird.Payload.CruiseProgress = 1;
end

if shouldBirdManeuver(bird, config)
    bird = generateBirdManeuver(bird, config);
end

bird.Payload.CurveWaypoint = computeCurvedCruiseTarget(bird, config);
end
