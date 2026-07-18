function targetOut = buildBaseTargetOutput(target)
% buildBaseTargetOutput - Основные выходные поля для каждой цели.
targetOut.ID = target.ID;
targetOut.Class = target.Class;
targetOut.Subtype = target.Subtype;
targetOut.Position = target.Position(:);
targetOut.Velocity = target.Velocity(:);
targetOut.Acceleration = target.Acceleration(:);
targetOut.StateMatrix = target.StateMatrix;
targetOut.RCS = target.RCS;
targetOut.Visible = target.Visible;
targetOut.State = target.State;
targetOut.Mission = target.Mission;
targetOut.TimeInState = target.TimeInState;
targetOut.CurrentTime = target.CurrentTime;
targetOut.RandomSeed = nan;
targetOut.TargetSeed = nan;
if isfield(target, 'Metadata') && isfield(target.Metadata, 'RandomSeed')
    targetOut.RandomSeed = target.Metadata.RandomSeed;
    targetOut.TargetSeed = target.Metadata.RandomSeed;
end
targetOut.BehaviorAction = "";
targetOut.BehaviorReason = "";
targetOut.BehaviorGoal = "";
targetOut.BehaviorProfile = "";
targetOut.RoadID = nan;
targetOut.CurrentEdgeID = nan;
targetOut.CurrentRoad = nan;
targetOut.Waypoint = nan(3, 1);
targetOut.SpeedLimit = nan;
targetOut.RoadDeviation = nan;
targetOut.RouteProgress = nan;
targetOut.LookaheadPoint = nan(3, 1);
targetOut.RouteRoadID = nan;
targetOut.OnRoad = false;
targetOut.IsOffRoad = false;
targetOut.DriverProfile = "";
targetOut.GroundAction = "";
targetOut.Decision = "";

if isfield(target, 'Behavior')
    targetOut.BehaviorAction = string(getBehaviorField(target.Behavior, 'LastDecision', ""));
    targetOut.BehaviorGoal = string(getBehaviorField(target.Behavior, 'CurrentGoal', ""));
    targetOut.BehaviorProfile = string(getBehaviorField(target.Behavior, 'Profile', ""));
    if isfield(target.Behavior, 'DecisionHistory') && ~isempty(target.Behavior.DecisionHistory)
        targetOut.BehaviorReason = string(target.Behavior.DecisionHistory(end).Reason);
    end
end
end
