function bird = applyBirdMotionLimits(bird, config)
% applyBirdMotionLimits - Apply speed and vertical velocity limits.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

state = string(bird.State);
motion = config.birds.motion;

if state == "Landing" && isfield(config.birds, 'landing') && config.birds.landing.enabled
    maxSpeed = config.birds.landing.speedRange(2);
    maxVz = config.birds.landing.maxVerticalSpeed;
else
    maxSpeed = motion.speedRange(2);
    maxVz = motion.maxVerticalSpeed;
end

bird.Velocity = limitVectorNorm(bird.Velocity, maxSpeed);

vz = bird.Velocity(3);
vz = max(min(vz, maxVz), -maxVz);
bird.Velocity(3) = vz;
end
