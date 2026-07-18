function target = appendTargetHistoryMinimal(target)
% appendTargetHistoryMinimal - Добавляет поля, необходимые для тестов и анализа.
target = appendTargetHistoryCore(target);

if ~isfield(target, 'Payload')
    return;
end

payload = target.Payload;
reason = getPayloadValue(payload, 'LastTransitionReason', "unknown");
count = getPayloadValue(payload, 'TransitionCount', 0);
target.History = appendHistoryScalar(target.History, 'TransitionReason', string(reason));
target.History = appendHistoryScalar(target.History, 'TransitionCount', count);

target.History = appendHistoryScalar(target.History, 'DesiredSpeed', ...
    getPayloadValue(payload, 'DesiredSpeed', 0));
target.History = appendHistoryScalar(target.History, 'DistanceToTargetTree', ...
    getPayloadValue(payload, 'DistanceToTargetTree', nan));
target.History = appendHistoryScalar(target.History, 'CruiseProgress', ...
    getPayloadValue(payload, 'CruiseProgress', 0));
target.History = appendHistoryScalar(target.History, 'CruiseLateralOffset', ...
    getPayloadValue(payload, 'CruiseLateralOffset', 0));
target.History = appendHistoryScalar(target.History, 'CruiseVerticalOffset', ...
    getPayloadValue(payload, 'CruiseVerticalOffset', 0));
curveWaypoint = getPayloadValue(payload, 'CurveWaypoint', nan(1, 3));
if isempty(curveWaypoint)
    curveWaypoint = nan(1, 3);
end
target.History = appendHistoryRow(target.History, 'CurveWaypoint', curveWaypoint(:).');
target.History = appendHistoryScalar(target.History, 'LandingProgress', ...
    getPayloadValue(payload, 'LandingProgress', 0));
target.History = appendHistoryScalar(target.History, 'LandingDistance', ...
    getPayloadValue(payload, 'LandingDistance', nan));
target.History = appendHistoryScalar(target.History, 'LastRealismEvent', ...
    string(getPayloadValue(payload, 'LastRealismEvent', "initial")));

behaviorAction = "";
behaviorReason = "";
behaviorGoal = "";
behaviorProfile = getPayloadValue(payload, 'BehaviorProfile', "normal");
if isfield(target, 'Behavior')
    behaviorAction = getBehaviorValue(target.Behavior, 'LastDecision', "");
    behaviorGoal = getBehaviorValue(target.Behavior, 'CurrentGoal', "");
    behaviorProfile = getBehaviorValue(target.Behavior, 'Profile', behaviorProfile);
    if isfield(target.Behavior, 'DecisionHistory') && ~isempty(target.Behavior.DecisionHistory)
        behaviorReason = string(target.Behavior.DecisionHistory(end).Reason);
    end
end
target.History = appendHistoryScalar(target.History, 'BehaviorAction', string(behaviorAction));
target.History = appendHistoryScalar(target.History, 'BehaviorReason', string(behaviorReason));
target.History = appendHistoryScalar(target.History, 'BehaviorGoal', string(behaviorGoal));
target.History = appendHistoryScalar(target.History, 'BehaviorProfile', string(behaviorProfile));

target = appendMinimalNavigationHistory(target);
target = appendMinimalGroundHistory(target);
target = appendMinimalAirHistory(target);
end

function target = appendMinimalNavigationHistory(target)
payload = target.Payload;
wpIdx = getPayloadValue(payload, 'CurrentWaypointIndex', nan);
distWp = getPayloadValue(payload, 'DistanceToWaypoint', nan);
missionDone = getPayloadValue(payload, 'MissionComplete', false);
navEvent = string(getPayloadValue(payload, 'LastNavigationEvent', ""));

target.History = appendHistoryScalar(target.History, 'WaypointIndex', wpIdx);
target.History = appendHistoryScalar(target.History, 'DistanceToWaypoint', distWp);
target.History = appendHistoryScalar(target.History, 'MissionComplete', logical(missionDone));
target.History = appendHistoryScalar(target.History, 'PreviousDistanceToWaypoint', ...
    getPayloadValue(payload, 'PreviousDistanceToWaypoint', nan));
target.History = appendHistoryScalar(target.History, 'NoProgressTime', ...
    getPayloadValue(payload, 'NoProgressTime', nan));
target.History = appendHistoryScalar(target.History, 'ForceDirectToWaypoint', ...
    logical(getPayloadValue(payload, 'ForceDirectToWaypoint', false)));
target.History = appendHistoryScalar(target.History, 'TotalXYExcursion', ...
    getPayloadValue(payload, 'TotalXYExcursion', nan));
target.History = appendHistoryScalar(target.History, 'MaxAltitudeReached', ...
    getPayloadValue(payload, 'MaxAltitudeReached', nan));
target.History = appendHistoryScalar(target.History, 'MinAltitudeReached', ...
    getPayloadValue(payload, 'MinAltitudeReached', nan));
target.History = appendHistoryScalar(target.History, 'LastNavigationEvent', navEvent);
end

function target = appendMinimalGroundHistory(target)
if target.Class ~= "ground" || target.Subtype ~= "vehicle"
    return;
end

payload = target.Payload;
currentRoad = getPayloadValue(payload, 'CurrentRoadID', nan);
currentWaypoint = getPayloadValue(payload, 'CurrentWaypoint', nan(3, 1));
decision = string(getPayloadValue(payload, 'LastDecision', ""));
lookaheadPoint = getPayloadValue(payload, 'LookaheadPoint', nan(3, 1));

target.History = appendHistoryScalar(target.History, 'CurrentRoad', currentRoad);
target.History = appendHistoryScalar(target.History, 'RoadID', currentRoad);
target.History = appendHistoryScalar(target.History, 'CurrentEdgeID', ...
    getPayloadValue(payload, 'CurrentEdgeID', nan));
target.History = appendHistoryRow(target.History, 'Waypoint', currentWaypoint(:).');
target.History = appendHistoryScalar(target.History, 'Decision', decision);
target.History = appendHistoryScalar(target.History, 'RoadDeviation', ...
    getPayloadValue(payload, 'RoadDeviation', nan));
target.History = appendHistoryScalar(target.History, 'SpeedLimit', ...
    getPayloadValue(payload, 'SpeedLimit', nan));
target.History = appendHistoryScalar(target.History, 'RouteProgress', ...
    getPayloadValue(payload, 'RouteProgress', nan));
target.History = appendHistoryRow(target.History, 'LookaheadPoint', lookaheadPoint(:).');
target.History = appendHistoryScalar(target.History, 'RouteRoadID', ...
    getPayloadValue(payload, 'RouteRoadID', currentRoad));
target.History = appendHistoryScalar(target.History, 'OnRoad', ...
    logical(getPayloadValue(payload, 'OnRoad', false)));
target.History = appendHistoryScalar(target.History, 'IsOffRoad', ...
    logical(getPayloadValue(payload, 'IsOffRoad', false)));
target.History = appendHistoryScalar(target.History, 'DriverProfile', ...
    string(getPayloadValue(payload, 'DriverProfile', "")));
target.History = appendHistoryScalar(target.History, 'GroundAction', ...
    string(getPayloadValue(payload, 'GroundAction', decision)));
end

function target = appendMinimalAirHistory(target)
if target.Class ~= "air" || target.Subtype ~= "fixedWingUAV"
    return;
end

isFW2 = isfield(target, 'Metadata') && isfield(target.Metadata, 'FW2') && target.Metadata.FW2;
if isFW2
    target.History = fw2_appendHistoryFields(target.History, target);
    return;
end

payload = target.Payload;
target.History = appendHistoryScalar(target.History, 'CurrentHeading', ...
    getPayloadValue(payload, 'CurrentHeading', nan));
target.History = appendHistoryScalar(target.History, 'DistanceToBoundary', ...
    getPayloadValue(payload, 'DistanceToBoundary', inf));
target.History = appendHistoryScalar(target.History, 'BorderFollowingTime', ...
    getPayloadValue(payload, 'BorderFollowingTime', 0));
end

function history = appendHistoryScalar(history, fieldName, value)
if ~isfield(history, fieldName) || isempty(history.(fieldName))
    history.(fieldName) = value;
else
    history.(fieldName)(end + 1, 1) = value;
end
end

function history = appendHistoryRow(history, fieldName, rowValue)
if ~isfield(history, fieldName) || isempty(history.(fieldName))
    history.(fieldName) = rowValue;
else
    history.(fieldName)(end + 1, :) = rowValue;
end
end

function value = getBehaviorValue(behavior, fieldName, defaultValue)
if isfield(behavior, fieldName) && ~isempty(behavior.(fieldName))
    value = behavior.(fieldName);
else
    value = defaultValue;
end
end

function value = getPayloadValue(payload, fieldName, defaultValue)
if isfield(payload, fieldName) && ~isempty(payload.(fieldName))
    value = payload.(fieldName);
else
    value = defaultValue;
end
end
