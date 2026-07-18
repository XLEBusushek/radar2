function target = applyFixedWingHeadingSmoothing(target, targetHeading, config, dt)
% applyFixedWingHeadingSmoothing - Сгладить курс с учётом лимита скорости разворота.
arguments
    target (1, 1) struct
    targetHeading (1, 1) double
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

turnCfg = config.fixedWing.turn;
motion = config.fixedWing.motion;
oldHeading = target.Payload.SmoothedHeading;
if isempty(oldHeading) || isnan(oldHeading)
    oldHeading = target.Payload.CurrentHeading;
end

headingError = wrapToPiLocal(targetHeading - oldHeading);
maxTurnRate = computeFixedWingMaxTurnRate(target, config);
maxDelta = maxTurnRate * dt;
limitedDelta = min(max(headingError, -maxDelta), maxDelta);
if string(target.State) == "Loiter" && abs(limitedDelta) > 1e-9
    minLoiterDelta = min(deg2rad(4) * dt, maxDelta);
    limitedDelta = sign(limitedDelta) * max(abs(limitedDelta), minLoiterDelta);
elseif turnCfg.smoothingEnabled && ...
        ~(isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive) && ...
        ~(isfield(config.fixedWing, 'antiBounce') && config.fixedWing.antiBounce.enabled)
    limitedDelta = motion.headingSmoothing * limitedDelta;
end

newHeading = wrapToPiLocal(oldHeading + limitedDelta);
target.Payload.SmoothedHeading = newHeading;
target.Payload.CurrentHeading = newHeading;
target.Payload.TargetHeading = targetHeading;
target.Payload.DesiredHeading = targetHeading;
target.Payload.TurnRate = limitedDelta / dt;
target.Payload.TurnSeverity = computeTurnSeverity(newHeading, targetHeading);
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
