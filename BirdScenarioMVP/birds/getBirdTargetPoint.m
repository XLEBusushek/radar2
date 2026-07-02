function targetPoint = getBirdTargetPoint(bird)
% getBirdTargetPoint - Return the motion target point for the current bird state.
arguments
    bird (1, 1) struct
end

state = string(bird.State);

if state == "Cruise" && isfield(bird.Payload, 'ForceDirectToTarget') && ...
        bird.Payload.ForceDirectToTarget
    targetPoint = bird.Payload.TargetTreePosition(:);
    if isfield(bird.Payload, 'DesiredAltitude') && ~isempty(bird.Payload.DesiredAltitude)
        targetPoint(3) = bird.Payload.DesiredAltitude;
    end
    return;
end

if state == "Cruise" && isfield(bird.Payload, 'CircleBeforeLanding') && ...
        bird.Payload.CircleBeforeLanding && isfield(bird.Payload, 'CircleWaypoint') && ...
        ~isempty(bird.Payload.CircleWaypoint)
    targetPoint = bird.Payload.CircleWaypoint(:);
    return;
end

if state == "Cruise" && isfield(bird, 'Payload') && ...
        isfield(bird.Payload, 'CurveWaypoint') && ~isempty(bird.Payload.CurveWaypoint)
    targetPoint = bird.Payload.CurveWaypoint(:);
    return;
end

if ~isfield(bird, 'Payload') || isempty(bird.Payload.TargetTreePosition)
    targetPoint = bird.Position(:);
    return;
end

targetPoint = bird.Payload.TargetTreePosition(:);

if state == "Cruise" || state == "Takeoff"
    if isfield(bird.Payload, 'DesiredAltitude') && ~isempty(bird.Payload.DesiredAltitude)
        targetPoint(3) = bird.Payload.DesiredAltitude;
    end
end
end
