function outputStep = collectOutput(scenario, time)
% collectOutput - Collect simulation data for the current time step.
outputStep.Time = time;
outputStep.RandomMode = "";
outputStep.ScenarioSeed = nan;
if isfield(scenario, 'Random')
    outputStep.RandomMode = string(getStructField(scenario.Random, 'Mode', ""));
    outputStep.ScenarioSeed = getStructField(scenario.Random, 'ScenarioSeed', nan);
elseif isfield(scenario, 'Metadata')
    outputStep.RandomMode = string(getStructField(scenario.Metadata, 'RandomMode', ""));
    outputStep.ScenarioSeed = getStructField(scenario.Metadata, 'ScenarioSeed', nan);
end

if ~isfield(scenario, 'Targets') || isempty(scenario.Targets)
    outputStep.Targets = struct([]);
    outputStep.Birds = struct([]);
    return;
end

numTargets = numel(scenario.Targets);

for i = 1:numTargets
    target = scenario.Targets(i);

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

    if isfield(target, 'Payload')
        if isfield(target.Payload, 'LastTransitionReason')
            targetOut.TransitionReason = string(target.Payload.LastTransitionReason);
        else
            targetOut.TransitionReason = "";
        end
        if isfield(target.Payload, 'TransitionCount')
            targetOut.TransitionCount = target.Payload.TransitionCount;
        else
            targetOut.TransitionCount = 0;
        end
        if isfield(target.Payload, 'CurrentTreeID')
            targetOut.CurrentTreeID = target.Payload.CurrentTreeID;
        else
            targetOut.CurrentTreeID = [];
        end
        if isfield(target.Payload, 'TargetTreeID')
            targetOut.TargetTreeID = target.Payload.TargetTreeID;
        else
            targetOut.TargetTreeID = [];
        end
        targetOut.DesiredSpeed = getPayloadField(target.Payload, 'DesiredSpeed', 0);
        targetOut.DesiredVelocity = getPayloadField(target.Payload, 'DesiredVelocity', zeros(3, 1));
        targetOut.DesiredAltitude = getPayloadField(target.Payload, 'DesiredAltitude', []);
        targetOut.DistanceToTargetTree = getPayloadField(target.Payload, 'DistanceToTargetTree', []);
        targetOut.ArrivedToTargetTree = getPayloadField(target.Payload, 'ArrivedToTargetTree', false);
        targetOut.CruiseProgress = getPayloadField(target.Payload, 'CruiseProgress', 0);
        targetOut.CruiseLateralOffset = getPayloadField(target.Payload, 'CruiseLateralOffset', 0);
        targetOut.CruiseVerticalOffset = getPayloadField(target.Payload, 'CruiseVerticalOffset', 0);
        curveWp = getPayloadField(target.Payload, 'CurveWaypoint', []);
        if isempty(curveWp)
            targetOut.CurveWaypoint = [];
        else
            targetOut.CurveWaypoint = curveWp(:);
        end
        targetOut.LandingProgress = getPayloadField(target.Payload, 'LandingProgress', 0);
        targetOut.LandingDistance = getPayloadField(target.Payload, 'LandingDistance', []);
        targetOut.LandingComplete = getPayloadField(target.Payload, 'LandingComplete', false);
        landingTp = getPayloadField(target.Payload, 'LandingTargetPoint', []);
        if isempty(landingTp)
            targetOut.LandingTargetPoint = [];
        else
            targetOut.LandingTargetPoint = landingTp(:);
        end
        if targetOut.BehaviorProfile == ""
            targetOut.BehaviorProfile = string(getPayloadField(target.Payload, 'BehaviorProfile', "normal"));
        end
        targetOut.LastRealismEvent = string(getPayloadField(target.Payload, 'LastRealismEvent', "initial"));
        targetOut.RetargetCount = getPayloadField(target.Payload, 'RetargetCount', 0);
        targetOut.FlyByCount = getPayloadField(target.Payload, 'FlyByCount', 0);
        targetOut.IsSharpManeuverActive = getPayloadField(target.Payload, 'IsSharpManeuverActive', false);
        targetOut.CircleBeforeLanding = getPayloadField(target.Payload, 'CircleBeforeLanding', false);
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
        targetOut.CurrentHeading = nan;
        targetOut.TargetHeading = nan;
        targetOut.LoiterRadius = nan;
        targetOut.DiveTargetAltitude = nan;
        targetOut.FlightLevel = nan;
        targetOut.TargetFlightLevel = nan;
        targetOut.AltitudeError = nan;
        targetOut.DesiredClimbRate = nan;
        targetOut.ClimbAngleDeg = nan;
        targetOut.TurnSeverity = nan;
        targetOut.NavigationLookaheadPoint = nan(3, 1);
        targetOut.CornerCuttingActive = false;
        targetOut.FinalPhase = false;
        targetOut.FinalStrategy = "";
        targetOut.FinalPhaseStarted = false;
        targetOut.FinalMissionCompleted = false;
        targetOut.TimeInFinalPhase = 0;
        targetOut.DistanceToBoundary = nan;
        targetOut.NearBoundary = false;
        targetOut.OutsideBoundary = false;
        targetOut.BoundaryRecoveryActive = false;
        targetOut.RecoveryTarget = nan(3, 1);
        targetOut.RecoveryReason = "";
        targetOut.LastBoundaryEvent = "";
        targetOut.SafeZone = nan(1, 4);
        targetOut.WarningZone = nan(1, 4);
        targetOut.CriticalZone = nan(1, 4);
        targetOut.InSafeZone = false;
        targetOut.InWarningZone = false;
        targetOut.InCriticalZone = false;
        targetOut.BorderFollowing = false;
        targetOut.BorderFollowingTime = 0;
        targetOut.BorderSide = "";
        targetOut.NavigationMode = "";
        targetOut.CurrentWaypointIndex = nan;
        targetOut.NextWaypoint = nan(3, 1);
        targetOut.NavigationTarget = nan(3, 1);
        targetOut.LookaheadPoint = nan(3, 1);
        targetOut.HeadingErrorDeg = nan;
        targetOut.TurnRateCommandDeg = nan;
        targetOut.WaypointReached = false;
        targetOut.LoiterActive = false;
        targetOut.Action = "";
        targetOut.LastDecisionReason = "";
        targetOut.HeadingJumpDeg = nan;
        targetOut.TargetPointJump = nan;
        targetOut.AntiBounceActive = false;
        targetOut.LastAntiBounceEvent = "";
        targetOut.TimeOnCurrentLeg = nan;
        targetOut.RawNavigationTarget = nan(3, 1);
        targetOut.SmoothedNavigationTarget = nan(3, 1);
        targetOut.RawLookaheadPoint = nan(3, 1);
        targetOut.SmoothedLookaheadPoint = nan(3, 1);
        targetOut.RouteIndex = nan;
        targetOut.CurrentLegProgress = nan;
        targetOut.CurrentSpeed = nan;
        targetOut.TargetSpeed = nan;
        targetOut.BaseCruiseSpeed = nan;
        targetOut.SpeedProfileEvent = "";
        targetOut.CurrentFlightLevel = nan;
        targetOut.AltitudeError = nan;
        targetOut.AltitudeProfileEvent = "";
        targetOut.LastFW2Event = "";

        if target.Class == "air" && ismember(target.Subtype, ["quadcopter", "fixedWingUAV"])
            targetOut.WaypointIndex = getPayloadField(target.Payload, 'CurrentWaypointIndex', nan);
            targetOut.DistanceToWaypoint = getPayloadField(target.Payload, 'DistanceToWaypoint', nan);
            targetOut.MissionComplete = getPayloadField(target.Payload, 'MissionComplete', false);
            targetOut.HomePosition = getPayloadField(target.Payload, 'HomePosition', nan(3, 1));
            targetOut.CurrentWaypoint = getPayloadField(target.Payload, 'CurrentWaypoint', nan(3, 1));
            targetOut.NoProgressTime = getPayloadField(target.Payload, 'NoProgressTime', nan);
            targetOut.ForceDirectToWaypoint = getPayloadField(target.Payload, 'ForceDirectToWaypoint', false);
            targetOut.TotalXYExcursion = getPayloadField(target.Payload, 'TotalXYExcursion', nan);
            targetOut.MaxAltitudeReached = getPayloadField(target.Payload, 'MaxAltitudeReached', nan);
            targetOut.MinAltitudeReached = getPayloadField(target.Payload, 'MinAltitudeReached', nan);
            targetOut.LastNavigationEvent = string(getPayloadField(target.Payload, 'LastNavigationEvent', ""));
            if target.Subtype == "fixedWingUAV"
                isFW2 = isfield(target, 'Metadata') && isfield(target.Metadata, 'FW2') && target.Metadata.FW2;
                if isFW2
                    targetOut.RouteIndex = getPayloadField(target.Payload, 'RouteIndex', nan);
                    targetOut.CurrentLegProgress = getPayloadField(target.Payload, 'CurrentLegProgress', nan);
                    targetOut.CurrentHeading = getPayloadField(target.Payload, 'CurrentHeading', nan);
                    targetOut.TargetHeading = getPayloadField(target.Payload, 'TargetHeading', nan);
                    targetOut.HeadingErrorDeg = getPayloadField(target.Payload, 'HeadingErrorDeg', nan);
                    targetOut.TurnRateCommandDeg = getPayloadField(target.Payload, 'TurnRateCommandDeg', nan);
                    targetOut.CurrentSpeed = getPayloadField(target.Payload, 'CurrentSpeed', nan);
                    targetOut.TargetSpeed = getPayloadField(target.Payload, 'TargetSpeed', nan);
                    targetOut.BaseCruiseSpeed = getPayloadField(target.Payload, 'BaseCruiseSpeed', nan);
                    targetOut.SpeedProfileEvent = string(getPayloadField(target.Payload, 'SpeedProfileEvent', ""));
                    targetOut.CurrentFlightLevel = getPayloadField(target.Payload, 'CurrentFlightLevel', nan);
                    targetOut.FlightLevel = getPayloadField(target.Payload, 'FlightLevel', nan);
                    targetOut.TargetFlightLevel = getPayloadField(target.Payload, 'TargetFlightLevel', nan);
                    targetOut.AltitudeError = getPayloadField(target.Payload, 'AltitudeError', nan);
                    targetOut.DesiredClimbRate = getPayloadField(target.Payload, 'DesiredClimbRate', nan);
                    targetOut.ClimbAngleDeg = getPayloadField(target.Payload, 'ClimbAngleDeg', nan);
                    targetOut.AltitudeProfileEvent = string(getPayloadField(target.Payload, 'AltitudeProfileEvent', ""));
                    targetOut.DistanceToBoundary = getPayloadField(target.Payload, 'DistanceToBoundary', nan);
                    targetOut.InWarningZone = getPayloadField(target.Payload, 'InWarningZone', false);
                    targetOut.InCriticalZone = getPayloadField(target.Payload, 'InCriticalZone', false);
                    targetOut.BorderFollowing = getPayloadField(target.Payload, 'BorderFollowing', false);
                    targetOut.LastFW2Event = string(getPayloadField(target.Payload, 'LastFW2Event', ""));
                    targetOut.WaypointIndex = targetOut.RouteIndex;
                    targetOut.MissionComplete = getPayloadField(target.Payload, 'RouteComplete', false);
                    targetOut.HomePosition = getPayloadField(target.Payload, 'HomePoint', nan(3, 1));
                else
                targetOut.CurrentHeading = getPayloadField(target.Payload, 'CurrentHeading', nan);
                targetOut.TargetHeading = getPayloadField(target.Payload, 'TargetHeading', nan);
                targetOut.LoiterRadius = getPayloadField(target.Payload, 'LoiterRadius', nan);
                targetOut.DiveTargetAltitude = getPayloadField(target.Payload, 'DiveTargetAltitude', nan);
                targetOut.FlightLevel = getPayloadField(target.Payload, 'FlightLevel', nan);
                targetOut.TargetFlightLevel = getPayloadField(target.Payload, 'TargetFlightLevel', nan);
                targetOut.AltitudeError = getPayloadField(target.Payload, 'AltitudeError', nan);
                targetOut.DesiredClimbRate = getPayloadField(target.Payload, 'DesiredClimbRate', nan);
                targetOut.ClimbAngleDeg = getPayloadField(target.Payload, 'ClimbAngleDeg', nan);
                targetOut.TurnSeverity = getPayloadField(target.Payload, 'TurnSeverity', nan);
                targetOut.NavigationLookaheadPoint = getPayloadField(target.Payload, 'NavigationLookaheadPoint', nan(3, 1));
                targetOut.CornerCuttingActive = getPayloadField(target.Payload, 'CornerCuttingActive', false);
                targetOut.FinalPhase = getPayloadField(target.Payload, 'FinalPhase', false);
                targetOut.FinalStrategy = string(getPayloadField(target.Payload, 'FinalStrategy', ""));
                targetOut.FinalPhaseStarted = getPayloadField(target.Payload, 'FinalPhaseStarted', false);
                targetOut.FinalMissionCompleted = getPayloadField(target.Payload, 'FinalMissionCompleted', false);
                targetOut.TimeInFinalPhase = getPayloadField(target.Payload, 'TimeInFinalPhase', 0);
                targetOut.DistanceToBoundary = getPayloadField(target.Payload, 'DistanceToBoundary', nan);
                targetOut.NearBoundary = getPayloadField(target.Payload, 'NearBoundary', false);
                targetOut.OutsideBoundary = getPayloadField(target.Payload, 'OutsideBoundary', false);
                targetOut.BoundaryRecoveryActive = getPayloadField(target.Payload, 'BoundaryRecoveryActive', false);
                targetOut.RecoveryTarget = getPayloadField(target.Payload, 'RecoveryTarget', nan(3, 1));
                if isempty(targetOut.RecoveryTarget)
                    targetOut.RecoveryTarget = getPayloadField(target.Payload, 'BoundaryRecoveryTarget', nan(3, 1));
                end
                targetOut.RecoveryReason = string(getPayloadField(target.Payload, 'RecoveryReason', ""));
                targetOut.LastBoundaryEvent = string(getPayloadField(target.Payload, 'LastBoundaryEvent', "none"));
                targetOut.SafeZone = getPayloadField(target.Payload, 'SafeZone', nan(1, 4));
                targetOut.WarningZone = getPayloadField(target.Payload, 'WarningZone', nan(1, 4));
                targetOut.CriticalZone = getPayloadField(target.Payload, 'CriticalZone', nan(1, 4));
                targetOut.InSafeZone = getPayloadField(target.Payload, 'InSafeZone', false);
                targetOut.InWarningZone = getPayloadField(target.Payload, 'InWarningZone', false);
                targetOut.InCriticalZone = getPayloadField(target.Payload, 'InCriticalZone', false);
                targetOut.BorderFollowing = getPayloadField(target.Payload, 'BorderFollowing', false);
                targetOut.BorderFollowingTime = getPayloadField(target.Payload, 'BorderFollowingTime', 0);
                targetOut.BorderSide = string(getPayloadField(target.Payload, 'BorderSide', ""));
                targetOut.NavigationMode = string(getPayloadField(target.Payload, 'NavigationMode', "Mission"));
                targetOut.CurrentWaypointIndex = getPayloadField(target.Payload, 'CurrentWaypointIndex', nan);
                targetOut.NextWaypoint = getPayloadField(target.Payload, 'NextWaypoint', nan(3, 1));
                targetOut.NavigationTarget = getPayloadField(target.Payload, 'NavigationTarget', nan(3, 1));
                targetOut.LookaheadPoint = getPayloadField(target.Payload, 'LookaheadPoint', nan(3, 1));
                targetOut.HeadingErrorDeg = getPayloadField(target.Payload, 'HeadingErrorDeg', nan);
                targetOut.TurnRateCommandDeg = getPayloadField(target.Payload, 'TurnRateCommandDeg', nan);
                targetOut.WaypointReached = getPayloadField(target.Payload, 'WaypointReached', false);
                targetOut.LoiterActive = getPayloadField(target.Payload, 'LoiterActive', false);
                targetOut.Action = string(getPayloadField(target.Payload, 'Action', ""));
                targetOut.LastDecisionReason = string(getPayloadField(target.Payload, 'LastDecisionReason', ""));
                targetOut.HeadingJumpDeg = getPayloadField(target.Payload, 'HeadingJumpDeg', nan);
                targetOut.TargetPointJump = getPayloadField(target.Payload, 'TargetPointJump', nan);
                targetOut.AntiBounceActive = getPayloadField(target.Payload, 'AntiBounceActive', false);
                targetOut.LastAntiBounceEvent = string(getPayloadField(target.Payload, 'LastAntiBounceEvent', "none"));
                targetOut.TimeOnCurrentLeg = getPayloadField(target.Payload, 'TimeOnCurrentLeg', nan);
                targetOut.RawNavigationTarget = getPayloadField(target.Payload, 'RawNavigationTarget', nan(3, 1));
                targetOut.SmoothedNavigationTarget = getPayloadField(target.Payload, 'SmoothedNavigationTarget', nan(3, 1));
                targetOut.RawLookaheadPoint = getPayloadField(target.Payload, 'RawLookaheadPoint', nan(3, 1));
                targetOut.SmoothedLookaheadPoint = getPayloadField(target.Payload, 'SmoothedLookaheadPoint', nan(3, 1));
                end
            end
        elseif target.Class == "ground" && target.Subtype == "vehicle"
            targetOut.WaypointIndex = getPayloadField(target.Payload, 'CurrentWaypointIndex', nan);
            targetOut.DistanceToWaypoint = getPayloadField(target.Payload, 'DistanceToWaypoint', nan);
            targetOut.MissionComplete = getPayloadField(target.Payload, 'MissionComplete', false);
            targetOut.HomePosition = getPayloadField(target.Payload, 'HomePosition', nan(3, 1));
            targetOut.CurrentWaypoint = getPayloadField(target.Payload, 'CurrentWaypoint', nan(3, 1));
            targetOut.NoProgressTime = nan;
            targetOut.ForceDirectToWaypoint = false;
            targetOut.TotalXYExcursion = nan;
            targetOut.MaxAltitudeReached = nan;
            targetOut.MinAltitudeReached = nan;
            targetOut.LastNavigationEvent = string(getPayloadField(target.Payload, 'LastNavigationEvent', ""));
            targetOut.RoadID = getPayloadField(target.Payload, 'CurrentRoadID', nan);
            targetOut.CurrentEdgeID = getPayloadField(target.Payload, 'CurrentEdgeID', nan);
            targetOut.CurrentRoad = targetOut.RoadID;
            targetOut.Waypoint = targetOut.CurrentWaypoint;
            targetOut.SpeedLimit = getPayloadField(target.Payload, 'SpeedLimit', nan);
            targetOut.RoadDeviation = getPayloadField(target.Payload, 'RoadDeviation', nan);
            targetOut.RouteProgress = getPayloadField(target.Payload, 'RouteProgress', nan);
            targetOut.LookaheadPoint = getPayloadField(target.Payload, 'LookaheadPoint', nan(3, 1));
            targetOut.RouteRoadID = getPayloadField(target.Payload, 'RouteRoadID', targetOut.RoadID);
            targetOut.OnRoad = getPayloadField(target.Payload, 'OnRoad', false);
            targetOut.IsOffRoad = getPayloadField(target.Payload, 'IsOffRoad', ~targetOut.OnRoad);
            targetOut.DriverProfile = string(getPayloadField(target.Payload, 'DriverProfile', ""));
            targetOut.GroundAction = string(getPayloadField(target.Payload, 'GroundAction', targetOut.Decision));
            targetOut.Decision = string(getPayloadField(target.Payload, 'LastDecision', ""));
        else
            targetOut.WaypointIndex = nan;
            targetOut.DistanceToWaypoint = nan;
            targetOut.MissionComplete = false;
            targetOut.HomePosition = nan(3, 1);
            targetOut.CurrentWaypoint = nan(3, 1);
            targetOut.NoProgressTime = nan;
            targetOut.ForceDirectToWaypoint = false;
            targetOut.TotalXYExcursion = nan;
            targetOut.MaxAltitudeReached = nan;
            targetOut.MinAltitudeReached = nan;
            targetOut.LastNavigationEvent = "";
        end
    end

    outputStep.Targets(i) = targetOut;
end

birdMask = arrayfun(@(t) t.Class == "bird", outputStep.Targets);
if any(birdMask)
    outputStep.Birds = outputStep.Targets(birdMask);
else
    outputStep.Birds = struct([]);
end
groundMask = arrayfun(@(t) t.Class == "ground", outputStep.Targets);
if any(groundMask)
    outputStep.GroundVehicles = outputStep.Targets(groundMask);
else
    outputStep.GroundVehicles = struct([]);
end
fixedWingMask = arrayfun(@(t) t.Class == "air" && t.Subtype == "fixedWingUAV", outputStep.Targets);
if any(fixedWingMask)
    outputStep.FixedWingUAVs = outputStep.Targets(fixedWingMask);
else
    outputStep.FixedWingUAVs = struct([]);
end
end

function value = getStructField(s, fieldName, defaultValue)
if isfield(s, fieldName) && ~isempty(s.(fieldName))
    value = s.(fieldName);
else
    value = defaultValue;
end
end

function value = getBehaviorField(behavior, fieldName, defaultValue)
if isfield(behavior, fieldName) && ~isempty(behavior.(fieldName))
    value = behavior.(fieldName);
else
    value = defaultValue;
end
end

function value = getPayloadField(payload, fieldName, defaultValue)
if isfield(payload, fieldName) && ~isempty(payload.(fieldName))
    value = payload.(fieldName);
    if strcmp(fieldName, 'DesiredVelocity')
        value = value(:);
    end
else
    value = defaultValue;
end
end
