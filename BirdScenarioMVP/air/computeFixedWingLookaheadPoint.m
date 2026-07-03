function target = computeFixedWingLookaheadPoint(target, config)
% computeFixedWingLookaheadPoint - Select raw XY lookahead point with corner cutting.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

fw = config.fixedWing;
nav = fw.navigation;
state = string(target.State);

if isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive && ...
        ~isempty(target.Payload.BoundaryRecoveryTarget)
    lookaheadPoint = target.Payload.BoundaryRecoveryTarget(:);
    target.Payload.CornerCuttingActive = false;
    target.Payload.DistanceToNextWaypoint = nan;
    target.Payload.RawLookaheadPoint = lookaheadPoint;
    return;
end

switch state
    case "Loiter"
        target = computeLoiterLookahead(target, fw);
        target.Payload.RawLookaheadPoint = target.Payload.NavigationLookaheadPoint(:);
        return;
    case "Return"
        lookaheadPoint = target.Payload.HomePosition(:);
    case "ExitArea"
        lookaheadPoint = target.Payload.ExitPoint(:);
    otherwise
        useStableLeg = ~isfield(nav, 'stableLegLookaheadEnabled') || nav.stableLegLookaheadEnabled;
        if useStableLeg
            [lookaheadPoint, cornerActive] = computeFixedWingStableLookahead(target, config);
            distNext = nan;
            if target.Payload.CurrentWaypointIndex < size(target.Payload.Waypoints, 1)
                nextWp = target.Payload.Waypoints(target.Payload.CurrentWaypointIndex + 1, :).';
                distNext = norm(nextWp(1:2) - target.Position(1:2));
            end
        else
            [lookaheadPoint, cornerActive, distNext] = routeLookahead(target, nav, config);
        end
        if ~(isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive)
            [lookaheadPoint, avoidingBoundary, boundaryArcActive] = applyBoundaryAvoidance(lookaheadPoint, target, config);
            if avoidingBoundary
                if boundaryArcActive
                    target.Payload.LastNavigationEvent = "boundaryCornerArc";
                    cornerActive = true;
                else
                    target.Payload.LastNavigationEvent = "boundaryAvoidance";
                end
            end
        else
            avoidingBoundary = false;
        end
        target.Payload.CornerCuttingActive = cornerActive;
        target.Payload.DistanceToNextWaypoint = distNext;
        lookaheadPoint(3) = target.Payload.TargetFlightLevel;
        target.Payload.RawLookaheadPoint = lookaheadPoint(:);
        target.Payload.NavigationLookaheadPoint = lookaheadPoint(:);
        return;
end

lookaheadPoint(3) = target.Payload.TargetFlightLevel;
if ~(isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive)
    [lookaheadPoint, avoidingBoundary, boundaryArcActive] = applyBoundaryAvoidance(lookaheadPoint, target, config);
    if avoidingBoundary
        if boundaryArcActive
            target.Payload.LastNavigationEvent = "boundaryCornerArc";
        else
            target.Payload.LastNavigationEvent = "boundaryAvoidance";
        end
    end
end
target.Payload.CornerCuttingActive = false;
target.Payload.DistanceToNextWaypoint = nan;
target.Payload.RawLookaheadPoint = lookaheadPoint(:);
target.Payload.NavigationLookaheadPoint = lookaheadPoint(:);
end

function target = computeLoiterLookahead(target, fw)
if isempty(target.Payload.LoiterCenter)
    target.Payload.LoiterCenter = target.Position(:);
end
radius = max(target.Payload.LoiterRadius, fw.loiterRadiusRange(1));
angleStep = max(fw.navigation.waypointLookahead, 1) / radius * target.Payload.LoiterDirection;
lookaheadAngle = target.Payload.LoiterAngle + angleStep;
center = target.Payload.LoiterCenter(:);
lookaheadPoint = center + [radius * cos(lookaheadAngle); radius * sin(lookaheadAngle); 0];
lookaheadPoint(3) = target.Payload.TargetFlightLevel;
target.Payload.NavigationLookaheadPoint = lookaheadPoint(:);
target.Payload.DistanceToNextWaypoint = nan;
target.Payload.CornerCuttingActive = false;
end

function [lookaheadPoint, cornerActive, distNext] = routeLookahead(target, nav, config)
currentWp = target.Payload.CurrentWaypoint(:);
lookaheadPoint = currentWp;
cornerActive = false;
distNext = nan;

idx = target.Payload.CurrentWaypointIndex;
waypoints = target.Payload.Waypoints;
distCurrent = norm(currentWp(1:2) - target.Position(1:2));
useArc = isfield(nav, 'arcTurnEnabled') && nav.arcTurnEnabled;

if idx < size(waypoints, 1)
    nextWp = waypoints(idx + 1, :).';
    distNext = norm(nextWp(1:2) - target.Position(1:2));
    if idx > 1
        prevWp = waypoints(idx - 1, :).';
    else
        prevWp = target.Position(:);
    end
    legIn = currentWp(1:2) - prevWp(1:2);
    legOut = nextWp(1:2) - currentWp(1:2);
    if norm(legIn) < 1e-6 || norm(legOut) < 1e-6
        uIn = [1; 0];
        uOut = [1; 0];
        headingChangeDeg = 0;
    else
        uIn = legIn / norm(legIn);
        uOut = legOut / norm(legOut);
        headingChangeDeg = acosd(max(-1, min(1, dot(uIn, uOut))));
    end
    minTurnDeg = 15;
    if isfield(config.fixedWing.navigation, 'minHeadingChangeDeg')
        minTurnDeg = config.fixedWing.navigation.minHeadingChangeDeg;
    end
    if headingChangeDeg < minTurnDeg
        turnLead = nav.cornerCuttingRadius;
    else
        turnLead = computeTurnLeadDistance(prevWp, currentWp, nextWp, config);
    end
    inTurnZone = distCurrent <= max(turnLead, nav.cornerCuttingRadius * 1.5) && ...
        headingChangeDeg >= minTurnDeg && idx >= 2;

    if useArc && inTurnZone
        lookaheadPoint = computeFixedWingArcLookahead(target, currentWp, nextWp, config, prevWp);
        cornerActive = true;
    elseif nav.cornerCuttingEnabled && distCurrent <= nav.cornerCuttingRadius
        blend = 1 - distCurrent / max(nav.cornerCuttingRadius, 1);
        blend = min(max(blend, 0), 1);
        lookaheadPoint = (1 - blend) * currentWp + blend * nextWp;
        cornerActive = true;
    elseif distCurrent <= nav.waypointLookahead
        blend = 0.25 * (1 - distCurrent / max(nav.waypointLookahead, 1));
        lookaheadPoint = (1 - blend) * currentWp + blend * nextWp;
        cornerActive = blend > 0;
    end
end

lookaheadPoint(3) = target.Payload.TargetFlightLevel;
end

function lead = computeTurnLeadDistance(prevWp, currentWp, nextWp, config)
R = getFixedWingDesiredTurnRadius(config);
nav = config.fixedWing.navigation;
leadFactor = 1.0;
if isfield(nav, 'arcTurnLeadFactor')
    leadFactor = nav.arcTurnLeadFactor;
end
legIn = currentWp(1:2) - prevWp(1:2);
legOut = nextWp(1:2) - currentWp(1:2);
if norm(legIn) < 1e-6 || norm(legOut) < 1e-6
    lead = nav.cornerCuttingRadius;
    return;
end
uIn = legIn / norm(legIn);
uOut = legOut / norm(legOut);
halfAngle = acos(max(-1, min(1, dot(uIn, uOut))));
lead = R * tan(max(halfAngle, deg2rad(8)) / 2) * leadFactor + nav.cornerCuttingRadius * 0.5;
end

function [lookaheadPoint, active, arcActive] = applyBoundaryAvoidance(lookaheadPoint, target, config)
worldSize = config.world.size;
nav = config.fixedWing.navigation;
boundaryCfg = config.fixedWing.boundary;
margin = getNavValue(nav, 'boundaryMargin', 120);
active = false;
arcActive = false;

pos = target.Position(:);
velXY = target.Velocity(1:2);
if ~isempty(target.Payload.CurrentWaypoint)
    toWaypoint = target.Payload.CurrentWaypoint(1:2) - pos(1:2);
    if norm(toWaypoint) > margin && norm(velXY) > config.fixedWing.minSpeed * 0.4 && ...
            dot(toWaypoint, velXY) > 0
        return;
    end
end

useBoundaryArc = isfield(boundaryCfg, 'arcTurnEnabled') && boundaryCfg.arcTurnEnabled;
if useBoundaryArc
    [arcLookahead, arcActive] = computeFixedWingBoundaryArcLookahead(target, config, lookaheadPoint);
    if arcActive
        active = true;
        lookaheadPoint = arcLookahead;
        return;
    end
end

maxBlend = 0.22;
blendRamp = 350;
if isfield(boundaryCfg, 'avoidanceMaxBlend')
    maxBlend = boundaryCfg.avoidanceMaxBlend;
end
if isfield(boundaryCfg, 'avoidanceBlendRamp')
    blendRamp = boundaryCfg.avoidanceBlendRamp;
end
lookaheadDist = 300;
if isfield(config.fixedWing, 'antiBounce') && isfield(config.fixedWing.antiBounce, 'lookaheadMinDistance')
    lookaheadDist = config.fixedWing.antiBounce.lookaheadMinDistance;
end

distLeft = pos(1);
distRight = worldSize(1) - pos(1);
distBottom = pos(2);
distTop = worldSize(2) - pos(2);
minDistToEdge = min([distLeft, distRight, distBottom, distTop]);

inward = [0; 0];
if distLeft < margin
    inward(1) = inward(1) + 1;
elseif distRight < margin
    inward(1) = inward(1) - 1;
end
if distBottom < margin
    inward(2) = inward(2) + 1;
elseif distTop < margin
    inward(2) = inward(2) - 1;
end

if norm(inward) < 1e-6
    return;
end

active = true;
inward = inward / norm(inward);
edgeDist = max(minDistToEdge, 0);
blend = maxBlend * (1 - edgeDist / max(blendRamp, 1));
blend = min(max(blend, 0), maxBlend);
inwardPoint = [pos(1:2) + inward * lookaheadDist; target.Payload.TargetFlightLevel];
inwardPoint(1) = min(max(inwardPoint(1), margin), worldSize(1) - margin);
inwardPoint(2) = min(max(inwardPoint(2), margin), worldSize(2) - margin);
lookaheadPoint = (1 - blend) * lookaheadPoint(:) + blend * inwardPoint(:);
lookaheadPoint(3) = target.Payload.TargetFlightLevel;
end

function value = getNavValue(nav, fieldName, defaultValue)
if isfield(nav, fieldName)
    value = nav.(fieldName);
else
    value = defaultValue;
end
end
