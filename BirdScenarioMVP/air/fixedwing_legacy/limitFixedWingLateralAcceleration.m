function target = limitFixedWingLateralAcceleration(target, config, dt)
% limitFixedWingLateralAcceleration - Ограничить команду курса лимитом бокового ускорения.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if ~isfield(config.fixedWing, 'antiBounce') || ~config.fixedWing.antiBounce.enabled
    return;
end

maxTurnRate = computeFixedWingMaxTurnRate(target, config);

heading = target.Payload.SmoothedHeading;
if isempty(heading) || isnan(heading)
    heading = target.Payload.CurrentHeading;
end

targetHeading = target.Payload.SmoothedTargetHeading;
if isempty(targetHeading) || isnan(targetHeading)
    targetHeading = target.Payload.TargetHeading;
end

headingError = wrapToPiLocal(targetHeading - heading);
maxDelta = maxTurnRate * dt;
limitedDelta = min(max(headingError, -maxDelta), maxDelta);
limitedHeading = wrapToPiLocal(heading + limitedDelta);

target.Payload.SmoothedTargetHeading = limitedHeading;
target.Payload.TargetHeading = limitedHeading;
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
