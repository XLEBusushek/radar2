function target = updateFixedWingBoundaryState(target, config, dt)
% updateFixedWingBoundaryState - Track flight zones and proactive recovery.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if ~isfield(config.fixedWing, 'boundary') || ~config.fixedWing.boundary.enabled
    return;
end

allowExitArea = isfield(config.fixedWing, 'allowExitArea') && config.fixedWing.allowExitArea;
state = string(target.State);
inReturnHomeFinal = isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted && ...
    isfield(target.Payload, 'FinalStrategy') && string(target.Payload.FinalStrategy) == "ReturnHome";
if allowExitArea && ismember(state, ["ApproachExit", "AlignExit", "Exit"])
    return;
end
if state == "ReturnHome" || inReturnHomeFinal
    zoneInfo = classifyFixedWingZone(target.Position, config);
    zones = getFixedWingZoneBounds(config);
    target.Payload.SafeZone = zones.SafeZone;
    target.Payload.WarningZone = zones.WarningZone;
    target.Payload.CriticalZone = zones.CriticalZone;
    target.Payload.DistanceToBoundary = zoneInfo.DistanceToBoundary;
    target.Payload.InSafeZone = zoneInfo.InSafeZone;
    target.Payload.InWarningZone = zoneInfo.InWarningZone;
    target.Payload.InCriticalZone = zoneInfo.InCriticalZone;
    target.Payload.OutsideBoundary = zoneInfo.OutsideBoundary;
    return;
end

zoneInfo = classifyFixedWingZone(target.Position, config);
zones = getFixedWingZoneBounds(config);

target.Payload.SafeZone = zones.SafeZone;
target.Payload.WarningZone = zones.WarningZone;
target.Payload.CriticalZone = zones.CriticalZone;
target.Payload.DistanceToBoundary = zoneInfo.DistanceToBoundary;
target.Payload.OutsideBoundary = zoneInfo.OutsideBoundary;
target.Payload.InSafeZone = zoneInfo.InSafeZone;
target.Payload.InWarningZone = zoneInfo.InWarningZone;
target.Payload.InCriticalZone = zoneInfo.InCriticalZone;
target.Payload.NearBoundary = zoneInfo.InWarningZone || zoneInfo.InCriticalZone;
target.Payload.BorderSide = zoneInfo.BorderSide;

if zoneInfo.OutsideBoundary
    target.Payload.TimeOutsideBoundary = target.Payload.TimeOutsideBoundary + dt;
    target.Payload.LastBoundaryEvent = "outsideBoundary";
elseif zoneInfo.InCriticalZone
    target.Payload.LastBoundaryEvent = "criticalZone";
elseif zoneInfo.InWarningZone
    target.Payload.LastBoundaryEvent = "warningZone";
else
    target.Payload.TimeOutsideBoundary = 0;
    if target.Payload.BoundaryRecoveryActive
        target.Payload.LastBoundaryEvent = "recoveryComplete";
    else
        target.Payload.LastBoundaryEvent = "insideBoundary";
    end
end

shouldRecover = zoneInfo.InWarningZone || zoneInfo.InCriticalZone || zoneInfo.OutsideBoundary;
recoveryReason = selectRecoveryReason(zoneInfo);

if target.Payload.BoundaryRecoveryActive && zoneInfo.InSafeZone && ...
        ~zoneInfo.InWarningZone && ~zoneInfo.InCriticalZone
    shouldRecover = false;
end

if shouldRecover && ~target.Payload.BoundaryRecoveryActive
    target.Payload.BoundaryRecoveryActive = true;
    target.Payload.RecoveryTarget = computeRecoveryTarget(target, config, recoveryReason);
    target.Payload.BoundaryRecoveryTarget = target.Payload.RecoveryTarget;
    target.Payload.RecoveryReason = recoveryReason;
    target.Payload.LastBoundaryEvent = "recoveryStarted";
    target.Payload.NavigationMode = "Recovery";
elseif target.Payload.BoundaryRecoveryActive && ~shouldRecover
    target.Payload.BoundaryRecoveryActive = false;
    target.Payload.RecoveryTarget = [];
    target.Payload.BoundaryRecoveryTarget = [];
    target.Payload.RecoveryReason = "";
    target.Payload.TimeOutsideBoundary = 0;
    target.Payload.LastBoundaryEvent = "recoveryComplete";
    if ~target.Payload.BorderFollowing
        target.Payload.NavigationMode = "Mission";
    end
end
end

function reason = selectRecoveryReason(zoneInfo)
if zoneInfo.OutsideBoundary
    reason = "outsideBoundary";
elseif zoneInfo.InCriticalZone
    reason = "criticalZone";
else
    reason = "warningZone";
end
end
