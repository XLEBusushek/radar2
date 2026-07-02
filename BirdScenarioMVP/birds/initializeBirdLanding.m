function bird = initializeBirdLanding(bird, scenario, config)
% initializeBirdLanding - Initialize landing parameters on Landing entry.
arguments
    bird (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
end

if isempty(bird.Payload.TargetTreeID)
    error('initializeBirdLanding:MissingTargetTree', ...
        'TargetTreeID must be set before landing.');
end

trees = scenario.Trees;
treeIdx = find([trees.ID] == bird.Payload.TargetTreeID, 1);
if isempty(treeIdx)
    error('initializeBirdLanding:TreeNotFound', ...
        'Target tree ID %d was not found.', bird.Payload.TargetTreeID);
end

targetTree = trees(treeIdx);
landingPoint = getTreeCrownPoint(targetTree);

jitterRadius = config.birds.landing.targetJitterRadius;
if jitterRadius > 0
    jitterDir = randn(3, 1);
    jitterDir = jitterDir / max(norm(jitterDir), 1e-9);
    jitter = jitterDir * (jitterRadius * rand());
    landingPoint = landingPoint + jitter;
end

landingPoint = enforceWorldBounds(landingPoint, config.world.size);

bird.Payload.LandingTargetPoint = landingPoint(:);
bird.Payload.LandingStartPosition = bird.Position(:);
bird.Payload.LandingProgress = 0;
bird.Payload.LandingComplete = false;
bird.Payload.LandingDistance = norm(landingPoint - bird.Position);
bird.Payload.LandingStartTime = bird.CurrentTime;
bird.Payload.LandingDesiredSpeed = randomInRange(config.birds.landing.speedRange);
if isfield(config.birds, 'realism') && config.birds.realism.enabled
    speedScale = 0.55 + rand() * 0.9;
    bird.Payload.LandingDesiredSpeed = bird.Payload.LandingDesiredSpeed * speedScale;
    bird.Payload.LandingDesiredSpeed = min(max(bird.Payload.LandingDesiredSpeed, ...
        config.birds.landing.speedRange(1)), config.birds.landing.speedRange(2));
end

bird = resetCruiseCurveFields(bird);
bird.Visible = true;
end

function value = randomInRange(range)
value = range(1) + rand() * (range(2) - range(1));
end
