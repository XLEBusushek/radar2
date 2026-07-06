function target = applyFixedWingSpeedSmoothing(target, config)
% applyFixedWingSpeedSmoothing - Smooth fixed-wing speed with gradual turn slowdown.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

fw = config.fixedWing;
motion = fw.motion;
alpha = motion.speedSmoothing;
if ~isfield(target.Payload, 'SmoothedDesiredSpeed') || isempty(target.Payload.SmoothedDesiredSpeed)
    target.Payload.SmoothedDesiredSpeed = max(norm(target.Velocity), fw.minSpeed);
end
if ~isfield(target.Payload, 'SmoothedTurnSeverity') || isempty(target.Payload.SmoothedTurnSeverity)
    target.Payload.SmoothedTurnSeverity = 0;
end

severityAlpha = 0.08;
if isfield(motion, 'turnSeveritySmoothing')
    severityAlpha = motion.turnSeveritySmoothing;
end
rawSeverity = min(max(target.Payload.TurnSeverity, 0), 1);
target.Payload.SmoothedTurnSeverity = target.Payload.SmoothedTurnSeverity + ...
    severityAlpha * (rawSeverity - target.Payload.SmoothedTurnSeverity);

targetSpeed = target.Payload.DesiredSpeed;
if isempty(targetSpeed) || isnan(targetSpeed)
    targetSpeed = mean(fw.cruiseSpeedRange);
end
targetSpeed = min(max(targetSpeed, fw.minSpeed), fw.maxSpeed);

severity = target.Payload.SmoothedTurnSeverity;
slowdown = 1 - severity * (1 - fw.turn.turnSlowdownFactor);
if isfield(target.Payload, 'CornerCuttingActive') && target.Payload.CornerCuttingActive && ...
        isfield(fw.turn, 'cornerSlowdownFactor')
    cornerAlpha = severityAlpha;
    if isfield(motion, 'cornerSlowdownSmoothing')
        cornerAlpha = motion.cornerSlowdownSmoothing;
    end
    if ~isfield(target.Payload, 'SmoothedCornerSlowdown') || isempty(target.Payload.SmoothedCornerSlowdown)
        target.Payload.SmoothedCornerSlowdown = 1;
    end
    target.Payload.SmoothedCornerSlowdown = target.Payload.SmoothedCornerSlowdown + ...
        cornerAlpha * (fw.turn.cornerSlowdownFactor - target.Payload.SmoothedCornerSlowdown);
    slowdown = slowdown * target.Payload.SmoothedCornerSlowdown;
else
    target.Payload.SmoothedCornerSlowdown = 1;
end
targetSpeed = targetSpeed * slowdown;
targetSpeed = min(max(targetSpeed, fw.minSpeed), fw.maxSpeed);

smoothedSpeed = target.Payload.SmoothedDesiredSpeed;
speedDelta = targetSpeed - smoothedSpeed;
maxIncrease = 1.2;
maxDecrease = 1.8;
if isfield(motion, 'maxSpeedIncreaseRate')
    maxIncrease = motion.maxSpeedIncreaseRate;
end
if isfield(motion, 'maxSpeedDecreaseRate')
    maxDecrease = motion.maxSpeedDecreaseRate;
end
speedDelta = min(max(speedDelta, -maxDecrease), maxIncrease);
smoothedSpeed = smoothedSpeed + alpha * speedDelta;
smoothedSpeed = min(max(smoothedSpeed, fw.minSpeed), fw.maxSpeed);

target.Payload.SmoothedDesiredSpeed = smoothedSpeed;
target.Payload.DesiredSpeed = smoothedSpeed;
end
