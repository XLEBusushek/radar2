function close = isCloseToTargetTreeForLanding(bird, config)
% isCloseToTargetTreeForLanding - Проверить горизонтальную близость к целевому дереву.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

close = false;

if ~isfield(bird.Payload, 'TargetTreePosition') || isempty(bird.Payload.TargetTreePosition)
    return;
end

targetPos = bird.Payload.TargetTreePosition(:);

if isfield(config.birds, 'landing') && config.birds.landing.enabled
    radius = config.birds.landing.approachRadius;
else
    radius = config.birds.motion.arrivalRadius;
end

close = norm(bird.Position(1:2) - targetPos(1:2)) <= radius;
end
