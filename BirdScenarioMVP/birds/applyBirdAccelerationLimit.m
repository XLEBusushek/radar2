function bird = applyBirdAccelerationLimit(bird, config, dt)
% applyBirdAccelerationLimit - Ограничить ускорение при движении к желаемой скорости.
arguments
    bird (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

desiredAcceleration = (bird.Payload.DesiredVelocity(:) - bird.Velocity(:)) / dt;
bird.Acceleration = limitVectorNorm(desiredAcceleration, config.birds.motion.maxAcceleration);
end
