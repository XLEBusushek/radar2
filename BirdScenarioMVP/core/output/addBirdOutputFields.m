function targetOut = addBirdOutputFields(targetOut, target)
% addBirdOutputFields - Bird-specific payload output fields.
payload = target.Payload;

if isfield(payload, 'LastTransitionReason')
    targetOut.TransitionReason = string(payload.LastTransitionReason);
else
    targetOut.TransitionReason = "";
end
if isfield(payload, 'TransitionCount')
    targetOut.TransitionCount = payload.TransitionCount;
else
    targetOut.TransitionCount = 0;
end
if isfield(payload, 'CurrentTreeID')
    targetOut.CurrentTreeID = payload.CurrentTreeID;
else
    targetOut.CurrentTreeID = [];
end
if isfield(payload, 'TargetTreeID')
    targetOut.TargetTreeID = payload.TargetTreeID;
else
    targetOut.TargetTreeID = [];
end

targetOut.DesiredSpeed = getPayloadField(payload, 'DesiredSpeed', 0);
targetOut.DesiredVelocity = getPayloadField(payload, 'DesiredVelocity', zeros(3, 1));
targetOut.DesiredAltitude = getPayloadField(payload, 'DesiredAltitude', []);
targetOut.DistanceToTargetTree = getPayloadField(payload, 'DistanceToTargetTree', []);
targetOut.ArrivedToTargetTree = getPayloadField(payload, 'ArrivedToTargetTree', false);
targetOut.CruiseProgress = getPayloadField(payload, 'CruiseProgress', 0);
targetOut.CruiseLateralOffset = getPayloadField(payload, 'CruiseLateralOffset', 0);
targetOut.CruiseVerticalOffset = getPayloadField(payload, 'CruiseVerticalOffset', 0);
curveWp = getPayloadField(payload, 'CurveWaypoint', []);
if isempty(curveWp)
    targetOut.CurveWaypoint = [];
else
    targetOut.CurveWaypoint = curveWp(:);
end
targetOut.LandingProgress = getPayloadField(payload, 'LandingProgress', 0);
targetOut.LandingDistance = getPayloadField(payload, 'LandingDistance', []);
targetOut.LandingComplete = getPayloadField(payload, 'LandingComplete', false);
landingTp = getPayloadField(payload, 'LandingTargetPoint', []);
if isempty(landingTp)
    targetOut.LandingTargetPoint = [];
else
    targetOut.LandingTargetPoint = landingTp(:);
end
if targetOut.BehaviorProfile == ""
    targetOut.BehaviorProfile = string(getPayloadField(payload, 'BehaviorProfile', "normal"));
end
targetOut.LastRealismEvent = string(getPayloadField(payload, 'LastRealismEvent', "initial"));
targetOut.RetargetCount = getPayloadField(payload, 'RetargetCount', 0);
targetOut.FlyByCount = getPayloadField(payload, 'FlyByCount', 0);
targetOut.IsSharpManeuverActive = getPayloadField(payload, 'IsSharpManeuverActive', false);
targetOut.CircleBeforeLanding = getPayloadField(payload, 'CircleBeforeLanding', false);
end
