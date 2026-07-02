function near = isFixedWingNearWaypointManeuverZone(target, config)
% isFixedWingNearWaypointManeuverZone - True when random maneuvers should be blocked.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

near = false;
if ~isfield(config, 'fixedWing') || ~isfield(config.fixedWing, 'antiBounce')
    return;
end
ab = config.fixedWing.antiBounce;
if ~ab.enabled || ~ab.disableRandomManeuversNearWaypoint
    return;
end

dist = computeFixedWingWaypointDistance(target);
near = dist < ab.nearWaypointRadius;

if ~near && isfield(target.Payload, 'NearBoundary') && target.Payload.NearBoundary
    near = true;
end
if ~near && isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive
    near = true;
end
if ~near && isfield(target.Payload, 'DistanceToBoundary') && ...
        ~isempty(target.Payload.DistanceToBoundary) && ~isnan(target.Payload.DistanceToBoundary)
    boundaryQuiet = 350;
    if isfield(config.fixedWing, 'navigation') && isfield(config.fixedWing.navigation, 'boundaryMargin')
        boundaryQuiet = config.fixedWing.navigation.boundaryMargin + 50;
    end
    near = target.Payload.DistanceToBoundary < boundaryQuiet;
end
end
