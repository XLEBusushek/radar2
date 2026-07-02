function maxTurnRate = computeFixedWingMaxTurnRate(target, config)
% computeFixedWingMaxTurnRate - Turn rate capped by config and desired turn radius.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

turnCfg = config.fixedWing.turn;
maxTurnRate = deg2rad(turnCfg.maxTurnRateDeg);

speed = target.Payload.SmoothedDesiredSpeed;
if isempty(speed) || isnan(speed)
    speed = norm(target.Velocity(1:2));
end
if isempty(speed) || isnan(speed) || speed < config.fixedWing.minSpeed
    speed = config.fixedWing.minSpeed;
end

desiredRadius = getFixedWingDesiredTurnRadius(config);
maxTurnRate = min(maxTurnRate, speed / desiredRadius);

if isfield(config.fixedWing, 'antiBounce') && config.fixedWing.antiBounce.enabled
    ab = config.fixedWing.antiBounce;
    maxTurnRate = min(maxTurnRate, ab.maxLateralAcceleration / max(speed, 1e-3));
end
end
