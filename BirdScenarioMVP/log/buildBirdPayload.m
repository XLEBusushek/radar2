function payload = buildBirdPayload(target)
% buildBirdPayload - Снимок Payload, специфичный для птицы.
payload = struct();
if ~isfield(target, 'Payload')
    return;
end
p = target.Payload;
fields = {'CurrentTreeID', 'TargetTreeID', 'DesiredSpeed', 'DesiredVelocity', ...
    'DesiredAltitude', 'DistanceToTargetTree', 'ArrivedToTargetTree', ...
    'CruiseProgress', 'CruiseLateralOffset', 'CruiseVerticalOffset', ...
    'CurveWaypoint', 'LandingProgress', 'LandingDistance', 'LandingComplete', ...
    'LandingTargetPoint', 'LastRealismEvent', 'RetargetCount', 'FlyByCount', ...
    'IsSharpManeuverActive', 'CircleBeforeLanding', 'TransitionCount', ...
    'LastTransitionReason', 'BehaviorProfile'};
for i = 1:numel(fields)
    if isfield(p, fields{i})
        payload.(fields{i}) = p.(fields{i});
    end
end
if isfield(target, 'Behavior')
    payload.BehaviorAction = string(getBehaviorFieldLocal(target.Behavior, 'LastDecision', ""));
    payload.BehaviorGoal = string(getBehaviorFieldLocal(target.Behavior, 'CurrentGoal', ""));
    payload.BehaviorProfile = string(getBehaviorFieldLocal(target.Behavior, 'Profile', payload.BehaviorProfile));
end
end

function value = getBehaviorFieldLocal(behavior, fieldName, defaultValue)
if isfield(behavior, fieldName) && ~isempty(behavior.(fieldName))
    value = behavior.(fieldName);
else
    value = defaultValue;
end
end
