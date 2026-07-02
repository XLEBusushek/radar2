function target = updateFixedWingBoundaryState(target, config, dt)
% updateFixedWingBoundaryState - Track boundary proximity and recovery flags.
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
if allowExitArea && ismember(state, ["ApproachExit", "AlignExit", "Exit"])
    return;
end

boundaryCfg = config.fixedWing.boundary;
worldSize = config.world.size;
[distanceToBoundary, outside] = computeDistanceToWorldBoundary(target.Position, worldSize);

target.Payload.DistanceToBoundary = distanceToBoundary;
target.Payload.OutsideBoundary = outside;
target.Payload.NearBoundary = distanceToBoundary < boundaryCfg.margin;

if outside
    target.Payload.TimeOutsideBoundary = target.Payload.TimeOutsideBoundary + dt;
    target.Payload.LastBoundaryEvent = "outsideBoundary";
elseif target.Payload.NearBoundary
    target.Payload.LastBoundaryEvent = "nearBoundary";
else
    target.Payload.TimeOutsideBoundary = 0;
    if target.Payload.BoundaryRecoveryActive
        target.Payload.LastBoundaryEvent = "recoveryComplete";
    else
        target.Payload.LastBoundaryEvent = "insideBoundary";
    end
end

shouldRecover = outside;
if ~shouldRecover && ~(isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted)
    recoveryTrigger = boundaryCfg.margin;
    if isfield(boundaryCfg, 'recoveryTriggerDistance')
        recoveryTrigger = boundaryCfg.recoveryTriggerDistance;
    end
    if distanceToBoundary <= recoveryTrigger
        velXY = target.Velocity(1:2);
        [outward, active] = computeOutwardNormalForRecovery(target.Position, worldSize, boundaryCfg.margin);
        if active && dot(velXY, outward) > 0.5
            shouldRecover = true;
        end
    end
end
if shouldRecover && ~target.Payload.BoundaryRecoveryActive
    target.Payload.BoundaryRecoveryActive = true;
    target.Payload.BoundaryRecoveryTarget = computeBoundaryRecoveryTarget(target, config);
    target.Payload.LastBoundaryEvent = "recoveryStarted";
elseif target.Payload.BoundaryRecoveryActive && ~shouldRecover && ~outside
    target.Payload.BoundaryRecoveryActive = false;
    target.Payload.TimeOutsideBoundary = 0;
    target.Payload.LastBoundaryEvent = "recoveryComplete";
end
end

function [outward, active] = computeOutwardNormalForRecovery(pos, worldSize, margin)
outward = [0; 0];
active = false;
if pos(1) <= margin
    outward = outward + [-1; 0];
    active = true;
elseif pos(1) >= worldSize(1) - margin
    outward = outward + [1; 0];
    active = true;
end
if pos(2) <= margin
    outward = outward + [0; -1];
    active = true;
elseif pos(2) >= worldSize(2) - margin
    outward = outward + [0; 1];
    active = true;
end
if active && norm(outward) > 1e-6
    outward = outward / norm(outward);
end
end
