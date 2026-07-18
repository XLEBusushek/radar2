function target = updateFixedWingNavigationDiagnostics(target, config)
% updateFixedWingNavigationDiagnostics - Снимок отладочных полей навигации на каждом тике.
arguments
    target (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
end

payload = target.Payload;
idx = payload.CurrentWaypointIndex;
waypoints = payload.Waypoints;

if idx < size(waypoints, 1)
    payload.NextWaypoint = waypoints(idx + 1, :).';
else
    payload.NextWaypoint = nan(3, 1);
end

if isfield(target.Payload, 'BoundaryRecoveryActive') && target.Payload.BoundaryRecoveryActive && ...
        isfield(target.Payload, 'BoundaryRecoveryTarget') && ~isempty(target.Payload.BoundaryRecoveryTarget)
    payload.NavigationTarget = payload.BoundaryRecoveryTarget(:);
elseif isfield(payload, 'SmoothedNavigationTarget') && ~isempty(payload.SmoothedNavigationTarget)
    payload.NavigationTarget = payload.SmoothedNavigationTarget(:);
else
    payload.NavigationTarget = payload.NavigationLookaheadPoint(:);
end

if isfield(payload, 'SmoothedLookaheadPoint') && ~isempty(payload.SmoothedLookaheadPoint)
    payload.LookaheadPoint = payload.SmoothedLookaheadPoint(:);
else
    payload.LookaheadPoint = payload.NavigationLookaheadPoint(:);
end
payload.HeadingErrorDeg = rad2deg(wrapToPiLocal(payload.TargetHeading - payload.CurrentHeading));

if isfield(payload, 'TurnRate') && ~isempty(payload.TurnRate)
    payload.TurnRateCommandDeg = rad2deg(payload.TurnRate);
else
    payload.TurnRateCommandDeg = 0;
end

arrivalRadius = payload.WaypointArrivalRadius;
if isfield(config, 'fixedWing') && isfield(config.fixedWing, 'navigation') && ...
        isfield(config.fixedWing.navigation, 'arrivalRadius')
    arrivalRadius = config.fixedWing.navigation.arrivalRadius;
end
payload.WaypointReached = payload.DistanceToWaypoint <= arrivalRadius;
payload.LoiterActive = string(target.State) == "Loiter";

if isfield(target, 'Behavior') && isfield(target.Behavior, 'LastDecision') && ...
        ~isempty(target.Behavior.LastDecision)
    payload.Action = string(target.Behavior.LastDecision);
else
    payload.Action = string(target.State);
end

payload.LastDecisionReason = resolveDecisionReason(target);

target.Payload = payload;
end

function reason = resolveDecisionReason(target)
reason = "";
if isfield(target, 'Behavior') && isfield(target.Behavior, 'DecisionHistory') && ...
        ~isempty(target.Behavior.DecisionHistory)
    reason = string(target.Behavior.DecisionHistory(end).Reason);
end
if reason == "" && isfield(target.Payload, 'LastTransitionReason')
    reason = string(target.Payload.LastTransitionReason);
end
if reason == ""
    reason = "unknown";
end
end

function angle = wrapToPiLocal(angle)
angle = mod(angle + pi, 2 * pi) - pi;
end
