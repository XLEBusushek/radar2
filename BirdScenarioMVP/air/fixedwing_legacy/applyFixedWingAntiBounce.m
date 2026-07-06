function target = applyFixedWingAntiBounce(target, config, dt)
% applyFixedWingAntiBounce - Full smoothed navigation chain for fixed-wing UAVs.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if ~isfield(config.fixedWing, 'antiBounce') || ~config.fixedWing.antiBounce.enabled
    return;
end

target.Payload.AntiBounceActive = false;
target.Payload.LastAntiBounceEvent = "none";

lookaheadReady = false;
if isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive
    recoveryTarget = target.Payload.BoundaryRecoveryTarget(:);
    if isempty(recoveryTarget)
        rawNavTarget = getFixedWingNavigationTarget(target, config);
    else
        boundaryCfg = config.fixedWing.boundary;
        useBoundaryArc = isfield(boundaryCfg, 'arcTurnEnabled') && boundaryCfg.arcTurnEnabled;
        arcLook = recoveryTarget;
        arcOn = false;
        if useBoundaryArc
            [arcLook, arcOn] = computeFixedWingBoundaryArcLookahead(target, config, recoveryTarget);
        end
        if arcOn
            rawNavTarget = arcLook(:);
        else
            lookaheadDist = 400;
            if isfield(config.fixedWing, 'antiBounce') && isfield(config.fixedWing.antiBounce, 'lookaheadMinDistance')
                lookaheadDist = config.fixedWing.antiBounce.lookaheadMinDistance;
            end
            deltaXY = recoveryTarget(1:2) - target.Position(1:2);
            if norm(deltaXY) > 1e-6
                rawNavTarget = [target.Position(1:2) + deltaXY / norm(deltaXY) * lookaheadDist; ...
                    target.Payload.TargetFlightLevel];
            else
                rawNavTarget = recoveryTarget;
            end
        end
    end
    target.Payload.RawLookaheadPoint = rawNavTarget(:);
else
    target = computeFixedWingLookaheadPoint(target, config);
    lookaheadReady = true;
    rawNavTarget = target.Payload.RawLookaheadPoint(:);
    if isempty(rawNavTarget) || any(isnan(rawNavTarget))
        rawNavTarget = getFixedWingNavigationTarget(target, config);
    end
end

target = smoothFixedWingNavigationTarget(target, rawNavTarget, config);

if isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive
    rawLookahead = target.Payload.RawLookaheadPoint(:);
    if isempty(rawLookahead)
        rawLookahead = target.Payload.SmoothedNavigationTarget(:);
    end
elseif lookaheadReady && ~isempty(target.Payload.RawLookaheadPoint)
    rawLookahead = target.Payload.RawLookaheadPoint(:);
else
    target = computeFixedWingLookaheadPoint(target, config);
    rawLookahead = target.Payload.RawLookaheadPoint(:);
    if isempty(rawLookahead) || any(isnan(rawLookahead))
        rawLookahead = target.Payload.SmoothedNavigationTarget(:);
    end
end

target = smoothFixedWingLookaheadPoint(target, rawLookahead, config);

look = target.Payload.SmoothedLookaheadPoint(:);
deltaXY = look(1:2) - target.Position(1:2);
if norm(deltaXY) > 1e-6
    rawHeading = atan2(deltaXY(2), deltaXY(1));
else
    rawHeading = target.Payload.CurrentHeading;
end

target = smoothFixedWingHeadingCommand(target, rawHeading, config, dt);
target = limitFixedWingLateralAcceleration(target, config, dt);
target = applyFixedWingHeadingSmoothing(target, target.Payload.SmoothedTargetHeading, config, dt);

target.Payload.NavigationTarget = target.Payload.SmoothedNavigationTarget(:);
end

function navTarget = getFixedWingNavigationTarget(target, config)
state = string(target.State);

if isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive && ...
        ~isempty(target.Payload.BoundaryRecoveryTarget)
    navTarget = target.Payload.BoundaryRecoveryTarget(:);
    return;
end

switch state
    case "Return"
        navTarget = target.Payload.HomePosition(:);
    case "ExitArea"
        navTarget = target.Payload.ExitPoint(:);
    otherwise
        navTarget = target.Payload.CurrentWaypoint(:);
end
navTarget(3) = target.Payload.TargetFlightLevel;
end
