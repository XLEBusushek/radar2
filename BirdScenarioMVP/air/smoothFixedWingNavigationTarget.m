function target = smoothFixedWingNavigationTarget(target, rawTarget, config)
% smoothFixedWingNavigationTarget - EMA-smooth navigation target with jump limit.
arguments
    target (1, 1) struct
    rawTarget (3, 1) double
    config (1, 1) struct
end

ab = config.fixedWing.antiBounce;
rawTarget = rawTarget(:);
oldSmoothed = target.Payload.SmoothedNavigationTarget;
if isempty(oldSmoothed)
    target.Payload.SmoothedNavigationTarget = rawTarget;
    target.Payload.RawNavigationTarget = rawTarget;
    target.Payload.PreviousNavigationTarget = rawTarget;
    target.Payload.TargetPointJump = 0;
    return;
end

jump = detectFixedWingTargetJump(rawTarget, oldSmoothed);
target.Payload.TargetPointJump = min(jump, ab.maxTargetPointJump);

if jump > ab.maxTargetPointJump
    target.Payload.AntiBounceActive = true;
    target.Payload.LastAntiBounceEvent = "navigationTargetJumpLimited";
    alpha = ab.navigationTargetSmoothing * 0.5;
else
    alpha = ab.navigationTargetSmoothing;
end

smoothed = (1 - alpha) * oldSmoothed + alpha * rawTarget;
smoothed(3) = rawTarget(3);
target.Payload.SmoothedNavigationTarget = smoothed;
target.Payload.RawNavigationTarget = rawTarget;
target.Payload.PreviousNavigationTarget = oldSmoothed;
end
