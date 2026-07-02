function bird = updateBirdKinematics(bird, config, dt)
% updateBirdKinematics - Update bird position, velocity, and acceleration.
arguments
    bird (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

state = string(bird.State);

if state == "Perched" || state == "Hidden"
    bird.Velocity = zeros(3, 1);
    bird.Acceleration = zeros(3, 1);
    bird.StateMatrix = computeStateMatrix(bird.Position, bird.Velocity);
    return;
end

if state == "Cruise"
    bird = updateBirdProgressToTarget(bird, config, dt);
end

bird = updateBirdMotionCommand(bird, config);
bird = computeBirdDesiredVelocity(bird, config);
bird = applyBirdAccelerationLimit(bird, config, dt);

bird.Velocity = bird.Velocity + bird.Acceleration * dt;
bird = applyBirdMotionLimits(bird, config);

bird.Position = bird.Position + bird.Velocity * dt;
bird.Position = enforceWorldBounds(bird.Position, config.world.size);

if state == "Cruise" && isfield(config.birds, 'curvedCruise')
    cc = config.birds.curvedCruise;
    bird.Position(3) = min(max(bird.Position(3), cc.minCruiseAltitude), cc.maxCruiseAltitude);
end

if state == "Landing" && isfield(config.birds, 'landing') && config.birds.landing.enabled
    landing = config.birds.landing;
    bird.Payload.LandingComplete = isBirdLandingComplete(bird, config);
    if bird.Payload.LandingComplete && ~isempty(bird.Payload.LandingTargetPoint)
        landingDist = norm(bird.Payload.LandingTargetPoint(:) - bird.Position(:));
        if landingDist > landing.touchdownDistance
            bird.Position = bird.Payload.LandingTargetPoint(:);
            bird.Velocity = zeros(3, 1);
            bird.Acceleration = zeros(3, 1);
        end
    end
end

bird.StateMatrix = computeStateMatrix(bird.Position, bird.Velocity);
end
