function bird = updateCircleBeforeLanding(bird, config)
% updateCircleBeforeLanding - Update circular approach waypoint before landing.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

if ~bird.Payload.CircleBeforeLanding
    return;
end

if isempty(bird.Payload.CircleCenter) || bird.Payload.CircleRadius <= 0
    bird.Payload.CircleBeforeLanding = false;
    return;
end

center = bird.Payload.CircleCenter(:);
radius = bird.Payload.CircleRadius;
direction = bird.Payload.CircleDirection;

if isempty(bird.Payload.CircleEndTime) || bird.CurrentTime >= bird.Payload.CircleEndTime
    bird.Payload.CircleBeforeLanding = false;
    bird.Payload.CircleEndTime = [];
    return;
end

rel = bird.Position(1:2) - center(1:2);
if norm(rel) < 1e-6
    rel = [1; 0];
else
    rel = rel / norm(rel);
end

angle = atan2(rel(2), rel(1));
angularSpeed = (2 * pi / max(bird.Payload.CircleEndTime - bird.CurrentTime, 1)) * 0.35;
angle = angle + direction * angularSpeed * config.sim.dt;

circlePoint = zeros(3, 1);
circlePoint(1:2) = center(1:2) + radius * [cos(angle); sin(angle)];
if isfield(bird.Payload, 'DesiredAltitude') && ~isempty(bird.Payload.DesiredAltitude)
    circlePoint(3) = bird.Payload.DesiredAltitude;
else
    circlePoint(3) = bird.Position(3);
end

circlePoint = enforceWorldBounds(circlePoint, config.world.size);
bird.Payload.CircleWaypoint = circlePoint;
bird.Payload.CurveWaypoint = circlePoint;
end
