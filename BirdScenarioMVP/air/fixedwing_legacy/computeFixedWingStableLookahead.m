function [lookaheadPoint, cornerActive] = computeFixedWingStableLookahead(target, config)
% computeFixedWingStableLookahead - Lookahead вдоль активного участка со смешиванием у конца.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

cornerActive = false;
nav = config.fixedWing.navigation;
pos = target.Position(:);

if ~isfield(target.Payload, 'ActiveLegStart') || isempty(target.Payload.ActiveLegStart)
    target = initializeFixedWingActiveLeg(target, config);
end

legStart = target.Payload.ActiveLegStart(:);
legEnd = target.Payload.ActiveLegEnd(:);
legDirection = target.Payload.ActiveLegDirection(:);
legLength = max(target.Payload.ActiveLegLength, 1);
nextDirection = target.Payload.NextLegDirection(:);
if isempty(nextDirection) || any(isnan(nextDirection))
    nextDirection = legDirection;
end

lookaheadDist = nav.waypointLookahead;
if isfield(config.fixedWing, 'turn') && isfield(config.fixedWing.turn, 'lookaheadDistance')
    lookaheadDist = max(lookaheadDist, config.fixedWing.turn.lookaheadDistance);
end

sAlong = dot(pos(1:2) - legStart(1:2), legDirection);
sLookahead = sAlong + lookaheadDist;

direction = legDirection;
blendZone = 0.25 * legLength;
if sAlong >= legLength - blendZone || ...
        (isfield(target.Payload, 'LegTransitionActive') && target.Payload.LegTransitionActive)
    if isfield(target.Payload, 'LegTransitionActive') && target.Payload.LegTransitionActive
        transitionDuration = getFixedWingNavConfigValue(config, 'legTransitionDuration', '', 8);
        elapsed = target.CurrentTime - target.Payload.LegTransitionStartTime;
        blend = min(max(elapsed / max(transitionDuration, 1e-3), 0), 1);
    else
        blend = min(max((sAlong - (legLength - blendZone)) / max(blendZone, 1), 0), 1);
    end
    direction = (1 - blend) * legDirection + blend * nextDirection;
    if norm(direction) > 1e-6
        direction = direction / norm(direction);
    else
        direction = legDirection;
    end
    cornerActive = blend > 0.05;
end

if sLookahead <= legLength
    xy = legStart(1:2) + sLookahead * direction;
else
    overshoot = sLookahead - legLength;
    xy = legEnd(1:2) + overshoot * nextDirection;
    cornerActive = true;
end

lookaheadPoint = [xy; target.Payload.TargetFlightLevel];
end
