function bird = maybeStartCircleBeforeLanding(bird, config)
% maybeStartCircleBeforeLanding - Begin a small orbit before landing.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

if string(bird.State) ~= "Cruise"
    return;
end

if bird.Payload.CircleBeforeLanding
    return;
end

if isfield(bird.Payload, 'ForceDirectToTarget') && bird.Payload.ForceDirectToTarget
    return;
end

if isfield(bird.Payload, 'SequentialFlyByCount') && ...
        bird.Payload.SequentialFlyByCount >= config.birds.realism.maxSequentialFlyBy
    return;
end

if isempty(bird.Payload.TargetTreePosition)
    return;
end

realism = config.birds.realism;
targetPos = bird.Payload.TargetTreePosition(:);
distXY = norm(bird.Position(1:2) - targetPos(1:2));
approachRadius = config.birds.landing.approachRadius;

if distXY > approachRadius || distXY <= config.birds.landing.finalRadius
    return;
end

if rand() >= realism.circleBeforeLandingProbability
    return;
end

radius = randomInRange(realism.circleRadiusRange);
duration = randomInRange(realism.circleDurationRange);
direction = 1;
if rand() < 0.5
    direction = -1;
end

bird.Payload.CircleBeforeLanding = true;
bird.Payload.CircleCenter = targetPos;
bird.Payload.CircleRadius = radius;
bird.Payload.CircleEndTime = bird.CurrentTime + duration;
bird.Payload.CircleDirection = direction;
bird.Payload.LastRealismEvent = "circleBeforeLanding";
end

function value = randomInRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
