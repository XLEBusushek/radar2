function target = updateFixedWingMotionCommand(target, config, dt)
% updateFixedWingMotionCommand - Compute fixed-wing heading and velocity command.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

target = computeFixedWingDesiredVelocity(target, config, dt);
end
