function bird = updateBirdProgressToTarget(bird, config, dt)
% updateBirdProgressToTarget - Отслеживать прогресс сближения и включать прямой полёт.
arguments
    bird (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if string(bird.State) ~= "Cruise"
    return;
end

if ~isfield(bird.Payload, 'TargetTreePosition') || isempty(bird.Payload.TargetTreePosition)
    return;
end

targetPos = bird.Payload.TargetTreePosition(:);
currentDist = norm(bird.Position(1:2) - targetPos(1:2));
progressTolerance = max(5.0, 0.02 * max(currentDist, 1.0));

if ~isfield(bird.Payload, 'PreviousDistanceToTargetTree') || ...
        isempty(bird.Payload.PreviousDistanceToTargetTree)
    bird.Payload.PreviousDistanceToTargetTree = currentDist;
    bird.Payload.NoProgressTime = 0;
    bird.Payload.BestDistanceToTargetTree = currentDist;
    return;
end

if ~isfield(bird.Payload, 'BestDistanceToTargetTree') || ...
        isempty(bird.Payload.BestDistanceToTargetTree)
    bird.Payload.BestDistanceToTargetTree = currentDist;
end

if currentDist < bird.Payload.BestDistanceToTargetTree - progressTolerance
    bird.Payload.BestDistanceToTargetTree = currentDist;
    bird.Payload.NoProgressTime = 0;
else
    bird.Payload.NoProgressTime = bird.Payload.NoProgressTime + dt;
end

bird.Payload.PreviousDistanceToTargetTree = currentDist;

if ~isfield(config.birds, 'realism') || ~config.birds.realism.enabled
    return;
end

if bird.Payload.NoProgressTime >= config.birds.realism.noProgressTimeLimit
    bird = enableDirectToTarget(bird);
end
end

function bird = enableDirectToTarget(bird)
bird.Payload.ForceDirectToTarget = true;
bird.Payload.CircleBeforeLanding = false;
bird.Payload.CircleCenter = [];
bird.Payload.CircleRadius = 0;
bird.Payload.CircleEndTime = [];
bird.Payload.IsSharpManeuverActive = false;
bird.Payload.SharpManeuverEndTime = [];
bird.Payload.SharpManeuverDirection = [0; 0; 0];
bird.Payload.CruiseLateralOffset = 0;
bird.Payload.CruiseVerticalOffset = 0;
if ~isempty(bird.Payload.TargetTreePosition)
    targetPoint = bird.Payload.TargetTreePosition(:);
    if isfield(bird.Payload, 'DesiredAltitude') && ~isempty(bird.Payload.DesiredAltitude)
        targetPoint(3) = bird.Payload.DesiredAltitude;
    end
    bird.Payload.CruiseTargetPosition = targetPoint;
    bird.Payload.CurveWaypoint = targetPoint;
end
bird.Payload.LastRealismEvent = "forceDirect";
end
