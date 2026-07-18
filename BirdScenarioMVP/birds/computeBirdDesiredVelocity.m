function bird = computeBirdDesiredVelocity(bird, config)
% computeBirdDesiredVelocity - Вычислить желаемый вектор скорости птицы.
arguments
    bird (1, 1) struct
    config (1, 1) struct
end

state = string(bird.State);
desiredSpeed = bird.Payload.DesiredSpeed;

if desiredSpeed == 0
    bird.Payload.DesiredVelocity = zeros(3, 1);
    return;
end

targetPoint = getBirdTargetPoint(bird);

switch state
    case "Takeoff"
        horizontalDir = targetPoint - bird.Position;
        horizontalDir(3) = 0;
        horizontalDirUnit = unitVector(horizontalDir);
        upDir = [0; 0; 1];
        direction = 0.4 * horizontalDirUnit + 0.6 * upDir;
        direction = unitVector(direction);
        bird.Payload.DesiredVelocity = direction * desiredSpeed;
        bird.Payload.FlightDirection = direction;

    case "Cruise"
        treePoint = [];
        if isfield(bird.Payload, 'CruiseTargetPosition') && ...
                ~isempty(bird.Payload.CruiseTargetPosition)
            treePoint = bird.Payload.CruiseTargetPosition(:);
        elseif isfield(bird.Payload, 'TargetTreePosition') && ...
                ~isempty(bird.Payload.TargetTreePosition)
            treePoint = bird.Payload.TargetTreePosition(:);
            if isfield(bird.Payload, 'DesiredAltitude') && ~isempty(bird.Payload.DesiredAltitude)
                treePoint(3) = bird.Payload.DesiredAltitude;
            end
        end

        if isfield(bird.Payload, 'ForceDirectToTarget') && bird.Payload.ForceDirectToTarget && ...
                ~isempty(treePoint)
            straightDir = unitVector(treePoint - bird.Position);
            if isfield(config.birds, 'realism') && isfield(config.birds.realism, 'directCourseBlend')
                blend = config.birds.realism.directCourseBlend;
            else
                blend = 0.9;
            end
            direction = straightDir;
            if norm(bird.Payload.FlightDirection) > 0 && blend < 1
                direction = unitVector(blend * straightDir + (1 - blend) * bird.Payload.FlightDirection(:));
            end
            bird.Payload.DesiredVelocity = direction * desiredSpeed;
            bird.Payload.FlightDirection = direction;
            return;
        end

        if ~isempty(treePoint)
            distXY = norm(bird.Position(1:2) - treePoint(1:2));
            approachRadius = config.birds.landing.approachRadius;
            if isfield(config.birds, 'landing') && config.birds.landing.enabled
                if distXY > approachRadius
                    direction = unitVector(treePoint - bird.Position);
                else
                    direction = unitVector(targetPoint - bird.Position);
                end
            else
                direction = unitVector(targetPoint - bird.Position);
            end
        else
            direction = unitVector(targetPoint - bird.Position);
        end

        if isfield(config.birds, 'curvedCruise') && config.birds.curvedCruise.enabled
            noiseStrength = config.birds.curvedCruise.noiseStrength;
            if isfield(bird.Payload, 'ProfileNoiseScale')
                noiseStrength = noiseStrength * bird.Payload.ProfileNoiseScale;
            end
            noise = noiseStrength * randn(3, 1);
            noise(3) = noise(3) * 0.3;
            direction = unitVector(direction + noise);
            curveBlend = config.birds.curvedCruise.curveBlend;
            if isfield(bird.Payload, 'ProfileCurveBlendScale')
                curveBlend = min(curveBlend * bird.Payload.ProfileCurveBlendScale, 0.95);
            end
            straightDir = unitVector(targetPoint - bird.Position);
            direction = unitVector((1 - curveBlend) * straightDir + curveBlend * direction);
        end
        if bird.Payload.IsSharpManeuverActive && ~isempty(bird.Payload.SharpManeuverEndTime) && ...
                bird.CurrentTime < bird.Payload.SharpManeuverEndTime && ...
                norm(bird.Payload.SharpManeuverDirection) > 0
            maneuverDir = unitVector(bird.Payload.SharpManeuverDirection);
            maneuverBlend = 0.55;
            direction = unitVector((1 - maneuverBlend) * direction + maneuverBlend * maneuverDir);
        end
        if norm(bird.Payload.FlightDirection) > 0 && config.birds.motion.directionBlend > 0
            blend = config.birds.motion.directionBlend;
            direction = unitVector((1 - blend) * direction + blend * bird.Payload.FlightDirection(:));
        end
        bird.Payload.DesiredVelocity = direction * desiredSpeed;
        bird.Payload.FlightDirection = direction;

    case "Landing"
        bird.Payload.DesiredVelocity = computeLandingDesiredVelocity(bird, config);
        if norm(bird.Payload.DesiredVelocity) > 0
            bird.Payload.FlightDirection = bird.Payload.DesiredVelocity / ...
                norm(bird.Payload.DesiredVelocity);
        end

    otherwise
        bird.Payload.DesiredVelocity = zeros(3, 1);
end
end

function vUnit = unitVector(v)
v = v(:);
n = norm(v);
if n == 0
    vUnit = zeros(3, 1);
else
    vUnit = v / n;
end
end
