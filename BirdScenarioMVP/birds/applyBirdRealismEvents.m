function bird = applyBirdRealismEvents(bird, scenario, config)
% applyBirdRealismEvents - Применить вероятностные реалистичные действия в крейсерском полёте.
arguments
    bird (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
end

if ~isfield(config.birds, 'realism') || ~config.birds.realism.enabled
    return;
end

if string(bird.State) ~= "Cruise"
    return;
end

bird.Payload.BlockLandingThisStep = false;

if isfield(bird.Payload, 'ForceDirectToTarget') && bird.Payload.ForceDirectToTarget
    bird = updateSharpManeuver(bird, config);
    return;
end

bird = maybeRetargetBird(bird, scenario, config);
bird = maybeStartSharpManeuver(bird, config);
bird = maybeStartCircleBeforeLanding(bird, config);
bird = updateSharpManeuver(bird, config);
bird = updateCircleBeforeLanding(bird, config);
end
