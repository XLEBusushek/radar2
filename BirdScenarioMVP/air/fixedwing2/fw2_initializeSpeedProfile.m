function target = fw2_initializeSpeedProfile(target, config)
% fw2_initializeSpeedProfile - Initialize speed profile fields at creation.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

sp = config.fixedWing2.speedProfile;
target.Payload.SpeedProfileEnabled = sp.enabled;

if sp.enabled
    baseSpeed = sp.cruiseSpeedRange(1) + rand() * diff(sp.cruiseSpeedRange);
else
    baseSpeed = config.fixedWing2.speed.cruiseRange(1) + ...
        rand() * diff(config.fixedWing2.speed.cruiseRange);
end

target.Payload.BaseCruiseSpeed = baseSpeed;
target.Payload.TargetSpeed = baseSpeed;
target.Payload.CurrentSpeed = baseSpeed;
target.Payload.LastSpeedChangeTime = target.CurrentTime;
interval = sp.speedChangeIntervalRange(1) + rand() * diff(sp.speedChangeIntervalRange);
target.Payload.NextSpeedChangeTime = target.CurrentTime + interval;
target.Payload.SpeedProfileEvent = "";

heading = target.Payload.CurrentHeading;
target.Velocity = [cos(heading); sin(heading); 0] * baseSpeed;
end
