function target = fw2_updateSpeedProfile(target, config, dt)
% fw2_updateSpeedProfile - Rare target speed changes with smooth tracking.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

fw2 = config.fixedWing2;
sp = fw2.speedProfile;

if ~sp.enabled
    return;
end

if target.CurrentTime >= target.Payload.NextSpeedChangeTime
    if rand() < sp.speedChangeProbability
        delta = (rand() * 2 - 1) * sp.legSpeedVariation;
        newTarget = target.Payload.BaseCruiseSpeed + delta;
        newTarget = min(max(newTarget, fw2.speed.minSpeed), fw2.speed.maxSpeed);
        target.Payload.TargetSpeed = newTarget;
        target.Payload.LastSpeedChangeTime = target.CurrentTime;
        target.Payload.SpeedProfileEvent = "speedChange";
    end
    interval = sp.speedChangeIntervalRange(1) + rand() * diff(sp.speedChangeIntervalRange);
    target.Payload.NextSpeedChangeTime = target.CurrentTime + interval;
elseif isfield(target.Payload, 'SpeedProfileEvent') && ...
        string(target.Payload.SpeedProfileEvent) == "speedChange"
    target.Payload.SpeedProfileEvent = "";
end

effectiveTarget = target.Payload.TargetSpeed;
state = string(target.State);
if state == "Turn"
    effectiveTarget = effectiveTarget * sp.turnSlowdownFactor;
elseif state == "BoundaryRecovery"
    effectiveTarget = effectiveTarget * sp.recoverySpeedFactor;
end
effectiveTarget = max(effectiveTarget, fw2.speed.minSpeed);
effectiveTarget = min(effectiveTarget, fw2.speed.maxSpeed);

speedError = effectiveTarget - target.Payload.CurrentSpeed;
maxDelta = sp.maxSpeedChangeRate * dt;
target.Payload.CurrentSpeed = target.Payload.CurrentSpeed + min(max(speedError, -maxDelta), maxDelta);
target.Payload.CurrentSpeed = min(max(target.Payload.CurrentSpeed, fw2.speed.minSpeed), fw2.speed.maxSpeed);
end
