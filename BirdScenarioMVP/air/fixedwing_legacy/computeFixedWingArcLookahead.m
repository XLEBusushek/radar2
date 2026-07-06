function lookaheadPoint = computeFixedWingArcLookahead(target, currentWp, nextWp, config, prevWp)
% computeFixedWingArcLookahead - Circular fly-by lookahead for waypoint turns.
arguments
    target (1, 1) struct
    currentWp (3, 1) double
    nextWp (3, 1) double
    config (1, 1) struct
    prevWp (3, 1) double = nan(3, 1)
end

pos = target.Position(:);
currentXY = currentWp(1:2);
nextXY = nextWp(1:2);
legOut = nextXY - currentXY;
if norm(legOut) < 1e-6
    lookaheadPoint = currentWp(:);
    return;
end
uOut = legOut / norm(legOut);

if ~any(isnan(prevWp))
    legIn = currentXY - prevWp(1:2);
    if norm(legIn) > 1e-6
        uIn = legIn / norm(legIn);
    else
        uIn = uOut;
    end
else
    velXY = target.Velocity(1:2);
    if norm(velXY) > 1e-3
        uIn = velXY / norm(velXY);
    else
        toWp = currentXY - pos(1:2);
        if norm(toWp) > 1e-6
            uIn = toWp / norm(toWp);
        else
            uIn = uOut;
        end
    end
end

R = getFixedWingDesiredTurnRadius(config);
lookaheadDist = getLookaheadDistance(config);
halfAngle = acos(max(-1, min(1, dot(uIn, uOut))));

if halfAngle < deg2rad(8)
    ahead = pos(1:2) + uOut * lookaheadDist;
    lookaheadPoint = [ahead; target.Payload.TargetFlightLevel];
    return;
end

crossZ = uIn(1) * uOut(2) - uIn(2) * uOut(1);
if abs(crossZ) < 1e-6
    ahead = pos(1:2) + uOut * lookaheadDist;
    lookaheadPoint = [ahead; target.Payload.TargetFlightLevel];
    return;
end

turnSign = sign(crossZ);
leftNormal = [-uIn(2); uIn(1)];
center = currentXY - uIn * R + turnSign * leftNormal * R;

leadFactor = 1.0;
if isfield(config.fixedWing.navigation, 'arcTurnLeadFactor')
    leadFactor = config.fixedWing.navigation.arcTurnLeadFactor;
end
leadIn = R * tan(max(halfAngle, deg2rad(8)) / 2) * leadFactor;
entryXY = currentXY - uIn * leadIn;
exitXY = currentXY + uOut * leadIn;
posXY = pos(1:2);

beforeEntry = dot(posXY - entryXY, uIn) < -5;
afterExit = dot(posXY - exitXY, uOut) > 5;

if beforeEntry
    ahead = posXY + uIn * lookaheadDist;
elseif afterExit
    ahead = posXY + uOut * lookaheadDist;
else
    fromCenter = posXY - center;
    distToCenter = norm(fromCenter);
    if distToCenter < 1e-6
        circlePoint = center + turnSign * leftNormal * R;
    else
        circlePoint = center + fromCenter / distToCenter * R;
    end
    arcRadial = circlePoint - center;
    if turnSign > 0
        tangent = [-arcRadial(2); arcRadial(1)];
    else
        tangent = [arcRadial(2); -arcRadial(1)];
    end
    tangent = tangent / max(norm(tangent), 1e-6);
    if dot(tangent, uIn) < 0
        tangent = -tangent;
    end
    ahead = posXY + tangent * lookaheadDist;
end

lookaheadPoint = [ahead; target.Payload.TargetFlightLevel];
end

function dist = getLookaheadDistance(config)
dist = 300;
if isfield(config.fixedWing, 'antiBounce') && isfield(config.fixedWing.antiBounce, 'lookaheadMinDistance')
    dist = config.fixedWing.antiBounce.lookaheadMinDistance;
end
if isfield(config.fixedWing, 'turn') && isfield(config.fixedWing.turn, 'lookaheadDistance')
    dist = max(dist, config.fixedWing.turn.lookaheadDistance);
end
end
