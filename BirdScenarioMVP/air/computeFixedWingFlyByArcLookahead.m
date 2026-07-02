function lookaheadPoint = computeFixedWingFlyByArcLookahead(posXY, cornerXY, uIn, uOut, config, flightLevel)
% computeFixedWingFlyByArcLookahead - Circular fly-by lookahead at a 90-degree corner.
arguments
    posXY (2, 1) double
    cornerXY (2, 1) double
    uIn (2, 1) double
    uOut (2, 1) double
    config (1, 1) struct
    flightLevel (1, 1) double
end

uIn = uIn(:) / max(norm(uIn), 1e-6);
uOut = uOut(:) / max(norm(uOut), 1e-6);

R = getFixedWingDesiredTurnRadius(config);
lookaheadDist = getArcLookaheadDistance(config);
halfAngle = acos(max(-1, min(1, dot(uIn, uOut))));

if halfAngle < deg2rad(8)
    ahead = posXY + uOut * lookaheadDist;
    lookaheadPoint = [ahead; flightLevel];
    return;
end

crossZ = uIn(1) * uOut(2) - uIn(2) * uOut(1);
if abs(crossZ) < 1e-6
    ahead = posXY + uOut * lookaheadDist;
    lookaheadPoint = [ahead; flightLevel];
    return;
end

turnSign = sign(crossZ);
leftNormal = [-uIn(2); uIn(1)];
center = cornerXY - uIn * R + turnSign * leftNormal * R;

leadFactor = 1.0;
if isfield(config.fixedWing.navigation, 'arcTurnLeadFactor')
    leadFactor = config.fixedWing.navigation.arcTurnLeadFactor;
end
if isfield(config.fixedWing, 'boundary') && isfield(config.fixedWing.boundary, 'cornerLeadFactor')
    leadFactor = max(leadFactor, config.fixedWing.boundary.cornerLeadFactor);
end

leadIn = R * tan(max(halfAngle, deg2rad(8)) / 2) * leadFactor;
entryXY = cornerXY - uIn * leadIn;
exitXY = cornerXY + uOut * leadIn;

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

lookaheadPoint = [ahead; flightLevel];
end

function dist = getArcLookaheadDistance(config)
dist = 300;
if isfield(config.fixedWing, 'antiBounce') && isfield(config.fixedWing.antiBounce, 'lookaheadMinDistance')
    dist = config.fixedWing.antiBounce.lookaheadMinDistance;
end
if isfield(config.fixedWing, 'turn') && isfield(config.fixedWing.turn, 'lookaheadDistance')
    dist = max(dist, config.fixedWing.turn.lookaheadDistance);
end
end
