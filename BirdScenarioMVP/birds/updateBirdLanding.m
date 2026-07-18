function bird = updateBirdLanding(bird, config)
% updateBirdLanding - Обновить прогресс посадки и желаемую скорость на каждом шаге.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

if isempty(bird.Payload.LandingTargetPoint)
    return;
end

landing = config.birds.landing;
targetPoint = bird.Payload.LandingTargetPoint(:);
startPos = bird.Payload.LandingStartPosition(:);

distance = norm(targetPoint - bird.Position(:));
bird.Payload.LandingDistance = distance;

startDistance = norm(targetPoint - startPos);
if startDistance > 1e-6
    progress = 1 - distance / startDistance;
else
    progress = 1;
end
bird.Payload.LandingProgress = min(max(progress, 0), 1);

slowdown = max(0.2, distance / landing.approachRadius);
desiredSpeed = landing.finalSpeed + ...
    slowdown * (bird.Payload.LandingDesiredSpeed - landing.finalSpeed);
bird.Payload.DesiredSpeed = desiredSpeed;

if isBirdLandingComplete(bird, config)
    bird.Payload.LandingComplete = true;
end
end
