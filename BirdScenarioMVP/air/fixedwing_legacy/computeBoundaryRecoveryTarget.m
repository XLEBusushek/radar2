function recoveryTarget = computeBoundaryRecoveryTarget(target, config)
% computeBoundaryRecoveryTarget - Legacy wrapper for computeRecoveryTarget.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

reason = "warningZone";
if isfield(target.Payload, 'RecoveryReason') && strlength(string(target.Payload.RecoveryReason)) > 0
    reason = string(target.Payload.RecoveryReason);
end
recoveryTarget = computeRecoveryTarget(target, config, reason);
end
