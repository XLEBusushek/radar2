function quad = updateQuadcopterNavigationProgress(quad, config, dt)
% updateQuadcopterNavigationProgress - Обнаружить застой при движении к текущей цели.
arguments
    quad (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

state = string(quad.State);
if ~ismember(state, ["Transit", "Return", "Landing"])
    return;
end

targetPoint = getNavigationTarget(quad, state, config);
distanceToTarget = norm(targetPoint(:) - quad.Position(:));
if state == "Transit"
    quad.Payload.DistanceToWaypoint = distanceToTarget;
end

previousDistance = quad.Payload.PreviousDistanceToWaypoint;
if isempty(previousDistance) || isnan(previousDistance)
    quad.Payload.PreviousDistanceToWaypoint = distanceToTarget;
    return;
end

if distanceToTarget < previousDistance - 0.5
    quad.Payload.NoProgressTime = 0;
else
    quad.Payload.NoProgressTime = quad.Payload.NoProgressTime + dt;
end

quad.Payload.PreviousDistanceToWaypoint = distanceToTarget;

if distanceToTarget <= getTargetTolerance(quad, state, config)
    quad = resetQuadcopterNavigationFlags(quad);
    quad.Payload.LastNavigationEvent = "targetReached";
    return;
end

nav = config.quadcopter.navigation;
if quad.Payload.NoProgressTime > nav.noProgressTimeLimit
    quad.Payload.ForceDirectToWaypoint = true;
    quad.Payload.LastNavigationEvent = "forceDirectToWaypoint";
end
end

function targetPoint = getNavigationTarget(quad, state, config)
switch state
    case "Transit"
        targetPoint = quad.Payload.CurrentWaypoint(:);
    case "Return"
        home = quad.Payload.HomePosition(:);
        safeAltitude = max(home(3), min(quad.Position(3), config.quadcopter.operatingAltitudeRange(1) + 30));
        targetPoint = [home(1); home(2); safeAltitude];
    case "Landing"
        home = quad.Payload.HomePosition(:);
        targetPoint = [home(1); home(2); 0];
    otherwise
        targetPoint = quad.Position(:);
end
end

function tolerance = getTargetTolerance(quad, state, config)
nav = config.quadcopter.navigation;
switch state
    case "Transit"
        tolerance = max(nav.xyTargetTolerance, quad.Payload.WaypointArrivalRadius);
    case "Return"
        tolerance = max(nav.xyTargetTolerance, quad.Payload.WaypointArrivalRadius);
    otherwise
        tolerance = config.quadcopter.landingAltitudeThreshold;
end
end
