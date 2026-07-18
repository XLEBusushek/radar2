function bird = resetLandingFields(bird)
% resetLandingFields - Очистить поля посадки в Payload.
bird.Payload.LandingTargetPoint = [];
bird.Payload.LandingStartPosition = [];
bird.Payload.LandingProgress = 0;
bird.Payload.LandingDesiredSpeed = 0;
bird.Payload.LandingComplete = false;
bird.Payload.LandingDistance = [];
bird.Payload.LandingStartTime = [];
end
