function bird = generateBirdManeuver(bird, config)
% generateBirdManeuver - Сгенерировать новый боковой/вертикальный манёвр в крейсерском полёте.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

cc = config.birds.curvedCruise;

lateralOffset = randomInRange(cc.lateralAmplitudeRange);
verticalOffset = randomInRange(cc.verticalAmplitudeRange);

if rand() < 0.5
    lateralOffset = -lateralOffset;
end
if rand() < 0.5
    verticalOffset = -verticalOffset;
end

if rand() < cc.altitudeChangeProbability
    bird.Payload.DesiredAltitude = randomInRange([cc.minCruiseAltitude, cc.maxCruiseAltitude]);
    bird.Payload.CruiseTargetPosition(3) = bird.Payload.DesiredAltitude;
end

bird.Payload.LastManeuverPosition = bird.Position(:);
bird.Payload.NextManeuverDistance = randomInRange(cc.maneuverDistanceRange);
bird.Payload.CruiseLateralOffset = lateralOffset;
bird.Payload.CruiseVerticalOffset = verticalOffset;
end

function value = randomInRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
