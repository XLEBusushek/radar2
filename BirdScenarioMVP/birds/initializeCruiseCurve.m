function bird = initializeCruiseCurve(bird, config)
% initializeCruiseCurve - Инициализировать параметры кривого крейсерского полёта при входе в Cruise.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

cc = config.birds.curvedCruise;

bird.Payload.CruiseStartPosition = bird.Position(:);
targetPoint = getBirdTargetPoint(bird);
bird.Payload.CruiseTargetPosition = targetPoint(:);

flightDir = bird.Payload.CruiseTargetPosition - bird.Payload.CruiseStartPosition;
bird.Payload.CruiseSideDirection = computePerpendicular2D(flightDir);

lateralOffset = randomInRange(cc.lateralAmplitudeRange);
verticalOffset = randomInRange(cc.verticalAmplitudeRange);
if isfield(bird.Payload, 'ProfileLateralScale')
    lateralOffset = lateralOffset * bird.Payload.ProfileLateralScale;
end
if isfield(bird.Payload, 'ProfileVerticalScale')
    verticalOffset = verticalOffset * bird.Payload.ProfileVerticalScale;
end
if rand() < 0.5
    lateralOffset = -lateralOffset;
end
if rand() < 0.5
    verticalOffset = -verticalOffset;
end

bird.Payload.CruiseLateralOffset = lateralOffset;
bird.Payload.CruiseVerticalOffset = verticalOffset;
bird.Payload.CruisePhase = 2 * pi * rand();
bird.Payload.CruiseProgress = 0;
bird.Payload.LastManeuverPosition = bird.Position(:);
bird.Payload.NextManeuverDistance = randomInRange(cc.maneuverDistanceRange);
bird.Payload.CurveWaypoint = targetPoint(:);
bird.Payload.CurveWaypoint = computeCurvedCruiseTarget(bird, config);
end

function value = randomInRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
