function target = smoothFixedWingNavigationTarget(target, rawTarget, config)
% smoothFixedWingNavigationTarget - EMA-сглаживание цели навигации с лимитом скачка.
arguments
    target (1, 1) struct
    rawTarget (3, 1) double
    config (1, 1) struct
end

ab = config.fixedWing.antiBounce;
rawTarget = rawTarget(:);
oldSmoothed = target.Payload.SmoothedNavigationTarget;
maxJump = getFixedWingNavConfigValue(config, 'maxTargetJump', 'maxTargetPointJump', 120);
alphaDefault = getFixedWingNavConfigValue(config, 'targetSmoothing', 'navigationTargetSmoothing', 0.08);
if isempty(oldSmoothed)
    target.Payload.SmoothedNavigationTarget = rawTarget;
    target.Payload.RawNavigationTarget = rawTarget;
    target.Payload.PreviousNavigationTarget = rawTarget;
    target.Payload.TargetPointJump = 0;
    return;
end

jump = detectFixedWingTargetJump(rawTarget, oldSmoothed);
target.Payload.TargetPointJump = min(jump, maxJump);

if jump > maxJump
    target.Payload.AntiBounceActive = true;
    target.Payload.LastAntiBounceEvent = "navigationTargetJumpLimited";
    alpha = alphaDefault * 0.5;
else
    alpha = alphaDefault;
end

smoothed = (1 - alpha) * oldSmoothed + alpha * rawTarget;
smoothed(3) = rawTarget(3);
target.Payload.SmoothedNavigationTarget = smoothed;
target.Payload.RawNavigationTarget = rawTarget;
target.Payload.PreviousNavigationTarget = oldSmoothed;
end
