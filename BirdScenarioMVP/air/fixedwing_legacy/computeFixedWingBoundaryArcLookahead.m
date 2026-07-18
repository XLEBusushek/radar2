function [lookaheadPoint, arcActive] = computeFixedWingBoundaryArcLookahead(target, config, routeLookahead)
% computeFixedWingBoundaryArcLookahead - Fly-by дуга на внутренних углах границы мира.
arguments
    target (1, 1) struct
    config (1, 1) struct
    routeLookahead (3, 1) double
end

arcActive = false;
lookaheadPoint = routeLookahead(:);
worldSize = config.world.size;
nav = config.fixedWing.navigation;
margin = getNavValue(nav, 'boundaryMargin', 120);

pos = target.Position(:);
posXY = pos(1:2);
flightLevel = target.Payload.TargetFlightLevel;

velXY = target.Velocity(1:2);
if norm(velXY) < config.fixedWing.minSpeed * 0.4
    velXY = routeLookahead(1:2) - posXY;
end
if norm(velXY) < 1e-3
    return;
end
uVel = velXY / norm(velXY);

R = getFixedWingDesiredTurnRadius(config);
leadFactor = 1.22;
if isfield(nav, 'arcTurnLeadFactor')
    leadFactor = nav.arcTurnLeadFactor;
end
if isfield(config.fixedWing.boundary, 'cornerLeadFactor')
    leadFactor = max(leadFactor, config.fixedWing.boundary.cornerLeadFactor);
end
turnLead = R * tan(deg2rad(45)) * leadFactor + margin * 0.35;
arcZoneDepth = turnLead + margin;

bestScore = -inf;
bestCorner = [];
bestUIn = [];
bestUOut = [];

cornerDefs = {
    [worldSize(1) - margin; worldSize(2) - margin], [1; 0], [0; -1], [0; 1], [-1; 0]
    [margin; worldSize(2) - margin], [-1; 0], [0; -1], [0; 1], [1; 0]
    [worldSize(1) - margin; margin], [1; 0], [0; 1], [0; -1], [-1; 0]
    [margin; margin], [-1; 0], [0; 1], [0; -1], [1; 0]
};

for k = 1:size(cornerDefs, 1)
    cornerXY = cornerDefs{k, 1};
    legAIn = cornerDefs{k, 2};
    legAOut = cornerDefs{k, 3};
    legBIn = cornerDefs{k, 4};
    legBOut = cornerDefs{k, 5};

    distToCorner = norm(posXY - cornerXY);
    if distToCorner > arcZoneDepth + R
        continue;
    end

    if dot(uVel, legAIn) >= dot(uVel, legBIn)
        uIn = legAIn;
        uOut = legAOut;
    else
        uIn = legBIn;
        uOut = legBOut;
    end

    toCorner = cornerXY - posXY;
    alongIn = dot(toCorner, uIn);
    if alongIn < -40 || alongIn > arcZoneDepth
        continue;
    end
    if dot(uVel, uIn) < 0.25
        continue;
    end

    score = dot(uVel, uIn) * 2 + max(0, 1 - alongIn / max(turnLead, 1)) - distToCorner / (arcZoneDepth + R);
    if score > bestScore
        bestScore = score;
        bestCorner = cornerXY;
        bestUIn = uIn;
        bestUOut = uOut;
    end
end

if isempty(bestCorner) || bestScore < 0.5
    return;
end

arcActive = true;
lookaheadPoint = computeFixedWingFlyByArcLookahead(posXY, bestCorner, bestUIn, bestUOut, config, flightLevel);
end

function value = getNavValue(nav, fieldName, defaultValue)
if isfield(nav, fieldName)
    value = nav.(fieldName);
else
    value = defaultValue;
end
end
