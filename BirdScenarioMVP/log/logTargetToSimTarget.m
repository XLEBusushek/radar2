function target = logTargetToSimTarget(targetLog, frameTime, includeStateMatrix)
% logTargetToSimTarget - Reconstruct a simulation target from a log snapshot.
arguments
    targetLog (1, 1) struct
    frameTime (1, 1) double
    includeStateMatrix (1, 1) logical = true
end

target.ID = targetLog.ID;
target.Class = string(targetLog.Type);
target.Subtype = string(targetLog.Subtype);
target.Position = targetLog.Position(:);
target.Velocity = targetLog.Velocity(:);
target.Acceleration = targetLog.Acceleration(:);
target.State = string(targetLog.State);
target.Mission = string(targetLog.Mission);
target.RCS = targetLog.RCS;
target.Visible = logical(targetLog.Visible);
target.TimeInState = targetLog.TimeInState;
target.CurrentTime = frameTime;
if includeStateMatrix
    target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
else
    target.StateMatrix = zeros(3, 2);
end

if isfield(targetLog, 'Payload')
    target.Payload = unwrapLogPayload(targetLog.Payload);
else
    target.Payload = struct();
end
target.Metadata = unwrapLogSnapshot(targetLog, 'MetadataSnapshot', ...
    struct('RandomSeed', nan, 'RandomMode', ""));
target.Behavior = unwrapLogSnapshot(targetLog, 'BehaviorSnapshot', struct());

if isfield(target.Payload, 'TargetSeed') && ~isnan(target.Payload.TargetSeed)
    target.Metadata.RandomSeed = target.Payload.TargetSeed;
end
end

function payload = unwrapLogPayload(payloadField)
if iscell(payloadField) && ~isempty(payloadField)
    payload = payloadField{1};
else
    payload = struct();
end
end

function value = unwrapLogSnapshot(targetLog, fieldName, defaultValue)
if isfield(targetLog, fieldName) && iscell(targetLog.(fieldName)) && ...
        ~isempty(targetLog.(fieldName))
    value = targetLog.(fieldName){1};
else
    value = defaultValue;
end
end
