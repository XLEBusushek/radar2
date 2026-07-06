function target = smoothFixedWingLookaheadPoint(target, rawLookahead, config)
% smoothFixedWingLookaheadPoint - Smooth lookahead with anti-backward logic.
arguments
    target (1, 1) struct
    rawLookahead (3, 1) double
    config (1, 1) struct
end

ab = config.fixedWing.antiBounce;
rawLookahead = rawLookahead(:);
pos = target.Position(:);
oldSmoothed = target.Payload.SmoothedLookaheadPoint;
maxJump = getFixedWingNavConfigValue(config, 'maxTargetJump', 'maxTargetPointJump', 120);
if isempty(oldSmoothed)
    target.Payload.SmoothedLookaheadPoint = rawLookahead;
    target.Payload.RawLookaheadPoint = rawLookahead;
    target.Payload.PreviousLookaheadPoint = rawLookahead;
    target.Payload.NavigationLookaheadPoint = rawLookahead;
    target.Payload.LookaheadPoint = rawLookahead;
    target.Payload.TargetPointJump = 0;
    return;
end
oldSmoothed = oldSmoothed(:);

target.Payload.PreviousLookaheadPoint = oldSmoothed;
target.Payload.RawLookaheadPoint = rawLookahead;

jump = detectFixedWingTargetJump(oldSmoothed, rawLookahead);
target.Payload.TargetPointJump = max(target.Payload.TargetPointJump, min(jump, maxJump));

deltaOld = oldSmoothed(1:2) - pos(1:2);
deltaRaw = rawLookahead(1:2) - pos(1:2);
if norm(deltaOld) > 1e-6 && norm(deltaRaw) > 1e-6
    forwardDot = dot(deltaOld / norm(deltaOld), deltaRaw / norm(deltaRaw));
    if forwardDot < 0
        target.Payload.AntiBounceActive = true;
        target.Payload.LastAntiBounceEvent = "lookaheadBackwardLimited";
        alpha = ab.lookaheadSmoothing * 0.35;
    else
        alpha = ab.lookaheadSmoothing;
    end
else
    alpha = ab.lookaheadSmoothing;
end

if jump > maxJump
    target.Payload.AntiBounceActive = true;
    target.Payload.LastAntiBounceEvent = "lookaheadJumpLimited";
    alpha = min(alpha, ab.lookaheadSmoothing * 0.5);
end

if isCornerOrBoundaryEvent(target)
    alpha = max(alpha, 0.12);
end

rawLookahead = clampLookaheadDistance(rawLookahead, pos, ab);
smoothed = (1 - alpha) * oldSmoothed + alpha * rawLookahead;
smoothed(3) = rawLookahead(3);
target.Payload.SmoothedLookaheadPoint = smoothed;
target.Payload.NavigationLookaheadPoint = smoothed;
target.Payload.LookaheadPoint = smoothed;
end

function point = clampLookaheadDistance(point, pos, ab)
delta = point(1:2) - pos(1:2);
dist = norm(delta);
if dist < 1e-6
    return;
end
clampedDist = min(max(dist, ab.lookaheadMinDistance), ab.lookaheadMaxDistance);
point(1:2) = pos(1:2) + delta / dist * clampedDist;
end

function active = isCornerOrBoundaryEvent(target)
active = false;
if isfield(target.Payload, 'CornerCuttingActive') && target.Payload.CornerCuttingActive
    active = true;
end
if isfield(target.Payload, 'LastNavigationEvent') && ...
        string(target.Payload.LastNavigationEvent) == "boundaryAvoidance"
    active = true;
end
if isfield(target.Payload, 'NearBoundary') && target.Payload.NearBoundary
    active = true;
end
end
