function complete = isBirdLandingComplete(bird, config)
% isBirdLandingComplete - Проверить, завершена ли посадка птицы.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

complete = false;

if ~isfield(config.birds, 'landing') || ~config.birds.landing.enabled
    return;
end

if isempty(bird.Payload.LandingTargetPoint)
    return;
end

landing = config.birds.landing;
distance = norm(bird.Payload.LandingTargetPoint(:) - bird.Position(:));

if distance <= landing.touchdownDistance
    complete = true;
elseif bird.TimeInState >= landing.maxLandingTime
    complete = true;
end
end
