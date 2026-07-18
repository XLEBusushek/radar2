function doManeuver = shouldBirdManeuver(bird, config)
% shouldBirdManeuver - Проверить, должна ли птица выполнить манёвр в крейсерском полёте.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

cc = config.birds.curvedCruise;

if isfield(bird.Payload, 'ForceDirectToTarget') && bird.Payload.ForceDirectToTarget
    doManeuver = false;
    return;
end

if isempty(bird.Payload.LastManeuverPosition) || isempty(bird.Payload.NextManeuverDistance)
    doManeuver = true;
    return;
end

distFromLast = norm(bird.Position(1:2) - bird.Payload.LastManeuverPosition(1:2));
doManeuver = distFromLast >= bird.Payload.NextManeuverDistance || ...
    rand() < cc.directionChangeProbability;
end
