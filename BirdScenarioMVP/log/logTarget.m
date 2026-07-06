function targetLog = logTarget(target, config)
% logTarget - Snapshot one target for a trajectory log frame.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

targetLog.ID = target.ID;
targetLog.Type = string(target.Class);
targetLog.Subtype = string(target.Subtype);
targetLog.Position = target.Position(:);
targetLog.Velocity = target.Velocity(:);
targetLog.Acceleration = target.Acceleration(:);
targetLog.State = string(target.State);
targetLog.Mission = string(target.Mission);
targetLog.RCS = target.RCS;
targetLog.Visible = logical(target.Visible);
targetLog.TimeInState = target.TimeInState;
targetLog.Heading = computeTargetHeading(target);
targetLog.Roll = 0;
targetLog.Pitch = 0;
targetLog.Yaw = targetLog.Heading;
targetLog.Payload = {buildTargetPayload(target, config)};
end

function heading = computeTargetHeading(target)
heading = atan2(target.Velocity(2), target.Velocity(1));
if isfield(target, 'Payload') && isfield(target.Payload, 'CurrentHeading') && ...
        ~isempty(target.Payload.CurrentHeading) && isfinite(target.Payload.CurrentHeading)
    heading = target.Payload.CurrentHeading;
end
end
