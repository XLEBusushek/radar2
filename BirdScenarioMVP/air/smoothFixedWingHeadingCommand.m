function target = smoothFixedWingHeadingCommand(target, rawTargetHeading, config, dt)
% smoothFixedWingHeadingCommand - Limit heading jumps and apply EMA smoothing.
arguments
    target (1, 1) struct
    rawTargetHeading (1, 1) double
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

ab = config.fixedWing.antiBounce;
previousHeading = target.Payload.PreviousTargetHeading;
if isempty(previousHeading) || isnan(previousHeading)
    previousHeading = target.Payload.SmoothedHeading;
end
if isempty(previousHeading) || isnan(previousHeading)
    previousHeading = target.Payload.CurrentHeading;
end

target.Payload.RawTargetHeading = rawTargetHeading;
if isempty(target.Payload.PreviousTargetHeading) || isnan(target.Payload.PreviousTargetHeading)
    initHeading = wrapToPiLocal(rawTargetHeading);
    target.Payload.PreviousTargetHeading = initHeading;
    target.Payload.SmoothedTargetHeading = initHeading;
    target.Payload.HeadingJumpDeg = 0;
    target.Payload.TargetHeading = initHeading;
    return;
end

jumpDeg = detectFixedWingHeadingJump(previousHeading, rawTargetHeading);
target.Payload.HeadingJumpDeg = min(jumpDeg, ab.maxHeadingJumpDeg);

delta = wrapToPiLocal(rawTargetHeading - previousHeading);
maxJump = deg2rad(ab.maxHeadingJumpDeg);
if abs(delta) > maxJump
    delta = sign(delta) * maxJump;
    target.Payload.AntiBounceActive = true;
    target.Payload.LastAntiBounceEvent = "headingJumpLimited";
end

alpha = ab.headingCommandSmoothing;
smoothedHeading = wrapToPiLocal(previousHeading + alpha * delta);
target.Payload.PreviousTargetHeading = smoothedHeading;
target.Payload.SmoothedTargetHeading = smoothedHeading;
target.Payload.TargetHeading = smoothedHeading;
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
