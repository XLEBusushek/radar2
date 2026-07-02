function bird = resetCruiseCurveFields(bird)
% resetCruiseCurveFields - Clear curved cruise payload fields.
bird.Payload.CruiseStartPosition = [];
bird.Payload.CruiseTargetPosition = [];
bird.Payload.CruiseProgress = 0;
bird.Payload.CruiseLateralOffset = 0;
bird.Payload.CruiseVerticalOffset = 0;
bird.Payload.CruiseSideDirection = zeros(3, 1);
bird.Payload.LastManeuverPosition = [];
bird.Payload.NextManeuverDistance = [];
bird.Payload.CruisePhase = 0;
bird.Payload.CurveWaypoint = [];
end
