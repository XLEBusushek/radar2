function bird = maybeStartSharpManeuver(bird, config)
% maybeStartSharpManeuver - Start a short sharp maneuver during cruise.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

if string(bird.State) ~= "Cruise"
    return;
end

if bird.Payload.IsSharpManeuverActive
    return;
end

realism = config.birds.realism;
if rand() >= realism.sharpManeuverProbability
    return;
end

baseDir = bird.Payload.FlightDirection(:);
if norm(baseDir) < 1e-6
    if ~isempty(bird.Payload.TargetTreePosition)
        baseDir = bird.Payload.TargetTreePosition(:) - bird.Position(:);
        baseDir(3) = 0;
    end
    if norm(baseDir) < 1e-6
        baseDir = [1; 0; 0];
    end
    baseDir = baseDir / norm(baseDir);
end

angleDeg = randomInRange(realism.sharpManeuverAngleRangeDeg);
angleRad = deg2rad(angleDeg);
sideDir = computePerpendicular2D(baseDir);
maneuverDir = cos(angleRad) * baseDir + sin(angleRad) * sideDir;
maneuverDir(3) = maneuverDir(3) * 0.2;
if norm(maneuverDir) > 0
    maneuverDir = maneuverDir / norm(maneuverDir);
end

duration = randomInRange(realism.sharpManeuverDurationRange);
bird.Payload.IsSharpManeuverActive = true;
bird.Payload.SharpManeuverEndTime = bird.CurrentTime + duration;
bird.Payload.SharpManeuverDirection = maneuverDir(:);
bird.Payload.LastRealismEvent = "sharpManeuver";
end

function value = randomInRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
