function desiredVelocity = computeLandingDesiredVelocity(bird, config)
% computeLandingDesiredVelocity - Compute desired velocity during landing.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

landing = config.birds.landing;
targetPoint = bird.Payload.LandingTargetPoint(:);
direction = targetPoint - bird.Position(:);

if norm(direction) < 1e-6
    desiredVelocity = zeros(3, 1);
    return;
end

direction = direction / norm(direction);
desiredSpeed = bird.Payload.DesiredSpeed;
desiredVelocity = direction * desiredSpeed;

maxVz = landing.maxVerticalSpeed;
desiredVelocity(3) = max(min(desiredVelocity(3), maxVz), -maxVz);
end
