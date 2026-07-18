function bird = applyBehaviorProfile(bird, config)
% applyBehaviorProfile - Назначить профиль полётного поведения одной птице.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

if ~isfield(config.birds, 'realism') || ~config.birds.realism.enabled
    bird.Payload.BehaviorProfile = "normal";
    bird.Payload.ProfileLateralScale = 1.0;
    bird.Payload.ProfileVerticalScale = 1.0;
    bird.Payload.ProfileNoiseScale = 1.0;
    bird.Payload.ProfileCurveBlendScale = 1.0;
    return;
end

realism = config.birds.realism;
r = rand();

if r < realism.straightFlightProbability
    profile = "straight";
    lateralScale = 0.25;
    verticalScale = 0.25;
    noiseScale = 0.15;
    curveBlendScale = 0.05;
elseif r < realism.straightFlightProbability + realism.strongCurveProbability
    profile = "curvy";
    lateralScale = 1.8;
    verticalScale = 1.5;
    noiseScale = 0.45;
    curveBlendScale = 0.5;
else
    profile = "normal";
    lateralScale = 1.0;
    verticalScale = 1.0;
    noiseScale = 1.0;
    curveBlendScale = 1.0;
end

bird.Payload.BehaviorProfile = profile;
bird.Payload.ProfileLateralScale = lateralScale;
bird.Payload.ProfileVerticalScale = verticalScale;
bird.Payload.ProfileNoiseScale = noiseScale;
bird.Payload.ProfileCurveBlendScale = curveBlendScale;
end
