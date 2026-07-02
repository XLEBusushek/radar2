function bird = updateBirdMotionCommand(bird, config)
% updateBirdMotionCommand - Set desired motion parameters based on bird state.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

motion = config.birds.motion;
state = string(bird.State);
worldZMax = config.world.size(3);

switch state
    case {"Perched", "Hidden"}
        bird.Payload.DesiredSpeed = 0;
        bird.Payload.DesiredVelocity = zeros(3, 1);

    case "Takeoff"
        if isempty(bird.Payload.TakeoffTargetAltitude)
            gain = randomInRange(motion.takeoffAltitudeGainRange);
            bird.Payload.TakeoffTargetAltitude = min(bird.Position(3) + gain, worldZMax);
        end
        if isempty(bird.Payload.DesiredSpeed) || bird.Payload.DesiredSpeed == 0
            bird.Payload.DesiredSpeed = randomInRange(motion.takeoffSpeedRange);
        end
        bird.Payload.DesiredAltitude = bird.Payload.TakeoffTargetAltitude;

    case "Cruise"
        if isempty(bird.Payload.DesiredAltitude) || ...
                bird.Payload.DesiredAltitude < motion.cruiseAltitudeRange(1)
            bird.Payload.DesiredAltitude = randomInRange(motion.cruiseAltitudeRange);
        end
        if isempty(bird.Payload.DesiredSpeed) || bird.Payload.DesiredSpeed == 0
            bird.Payload.DesiredSpeed = randomInRange(motion.cruiseSpeedRange);
        end
        if isfield(config.birds, 'curvedCruise') && config.birds.curvedCruise.enabled
            bird = updateCruiseCurve(bird, config);
        end

    case "Landing"
        if isfield(config.birds, 'landing') && config.birds.landing.enabled
            bird = updateBirdLanding(bird, config);
        elseif isempty(bird.Payload.DesiredSpeed) || bird.Payload.DesiredSpeed == 0
            bird.Payload.DesiredSpeed = randomInRange(motion.cruiseSpeedRange);
        end
end

if ~isempty(bird.Payload.TargetTreePosition)
    targetPos = bird.Payload.TargetTreePosition(:);
    bird.Payload.DistanceToTargetTree = norm(bird.Position(1:2) - targetPos(1:2));
    bird.Payload.ArrivedToTargetTree = ...
        bird.Payload.DistanceToTargetTree <= motion.arrivalRadius;
else
    bird.Payload.DistanceToTargetTree = [];
    bird.Payload.ArrivedToTargetTree = false;
end
end

function value = randomInRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
