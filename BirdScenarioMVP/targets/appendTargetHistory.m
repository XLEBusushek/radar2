function target = appendTargetHistory(target)
% appendTargetHistory - Append current target state to history buffers.
target.History.Time(end + 1, 1) = target.CurrentTime;
target.History.Position(end + 1, :) = target.Position(:).';
target.History.Velocity(end + 1, :) = target.Velocity(:).';
target.History.Acceleration(end + 1, :) = target.Acceleration(:).';
target.History.State(end + 1, 1) = string(target.State);
target.History.Visible(end + 1, 1) = logical(target.Visible);
target.History.RCS(end + 1, 1) = target.RCS;

if isfield(target, 'Payload')
    reason = "unknown";
    if isfield(target.Payload, 'LastTransitionReason')
        reason = string(target.Payload.LastTransitionReason);
    end
    count = 0;
    if isfield(target.Payload, 'TransitionCount')
        count = target.Payload.TransitionCount;
    end

    target.History = appendHistoryScalar(target.History, 'TransitionReason', reason);
    target.History = appendHistoryScalar(target.History, 'TransitionCount', count);

  desiredSpeed = getPayloadValue(target.Payload, 'DesiredSpeed', 0);
  desiredVelocity = getPayloadValue(target.Payload, 'DesiredVelocity', zeros(1, 3));
  desiredAltitude = getPayloadValue(target.Payload, 'DesiredAltitude', target.Position(3));
  distanceToTarget = getPayloadValue(target.Payload, 'DistanceToTargetTree', nan);

  target.History = appendHistoryScalar(target.History, 'DesiredSpeed', desiredSpeed);
  target.History = appendHistoryRow(target.History, 'DesiredVelocity', desiredVelocity(:).');
  target.History = appendHistoryScalar(target.History, 'DesiredAltitude', desiredAltitude);
  target.History = appendHistoryScalar(target.History, 'DistanceToTargetTree', distanceToTarget);

  cruiseProgress = getPayloadValue(target.Payload, 'CruiseProgress', 0);
  cruiseLateral = getPayloadValue(target.Payload, 'CruiseLateralOffset', 0);
  cruiseVertical = getPayloadValue(target.Payload, 'CruiseVerticalOffset', 0);
  curveWaypoint = getPayloadValue(target.Payload, 'CurveWaypoint', nan(1, 3));
  if isempty(curveWaypoint)
      curveWaypoint = nan(1, 3);
  end

  target.History = appendHistoryScalar(target.History, 'CruiseProgress', cruiseProgress);
  target.History = appendHistoryScalar(target.History, 'CruiseLateralOffset', cruiseLateral);
  target.History = appendHistoryScalar(target.History, 'CruiseVerticalOffset', cruiseVertical);
  target.History = appendHistoryRow(target.History, 'CurveWaypoint', curveWaypoint(:).');

  landingProgress = getPayloadValue(target.Payload, 'LandingProgress', 0);
  landingDistance = getPayloadValue(target.Payload, 'LandingDistance', nan);
  landingComplete = getPayloadValue(target.Payload, 'LandingComplete', false);
  landingTarget = getPayloadValue(target.Payload, 'LandingTargetPoint', nan(1, 3));
  if isempty(landingTarget)
      landingTarget = nan(1, 3);
  end

  target.History = appendHistoryScalar(target.History, 'LandingProgress', landingProgress);
  target.History = appendHistoryScalar(target.History, 'LandingDistance', landingDistance);
  target.History = appendHistoryScalar(target.History, 'LandingComplete', logical(landingComplete));
  target.History = appendHistoryRow(target.History, 'LandingTargetPoint', landingTarget(:).');

  behaviorProfile = getPayloadValue(target.Payload, 'BehaviorProfile', "normal");
  lastRealismEvent = getPayloadValue(target.Payload, 'LastRealismEvent', "initial");
  retargetCount = getPayloadValue(target.Payload, 'RetargetCount', 0);
  flyByCount = getPayloadValue(target.Payload, 'FlyByCount', 0);
  isSharpManeuver = getPayloadValue(target.Payload, 'IsSharpManeuverActive', false);
  circleBeforeLanding = getPayloadValue(target.Payload, 'CircleBeforeLanding', false);

  target.History = appendHistoryScalar(target.History, 'LastRealismEvent', string(lastRealismEvent));
  target.History = appendHistoryScalar(target.History, 'RetargetCount', retargetCount);
  target.History = appendHistoryScalar(target.History, 'FlyByCount', flyByCount);
  target.History = appendHistoryScalar(target.History, 'IsSharpManeuverActive', logical(isSharpManeuver));
  target.History = appendHistoryScalar(target.History, 'CircleBeforeLanding', logical(circleBeforeLanding));

  behaviorAction = "";
  behaviorReason = "";
  behaviorGoal = "";
  behaviorProfile = behaviorProfile;
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

  if target.Class == "ground" && target.Subtype == "vehicle"
      currentRoad = getPayloadValue(target.Payload, 'CurrentRoadID', nan);
      currentWaypoint = getPayloadValue(target.Payload, 'CurrentWaypoint', nan(3, 1));
      decision = getPayloadValue(target.Payload, 'LastDecision', string(behaviorAction));
      roadDeviation = getPayloadValue(target.Payload, 'RoadDeviation', nan);
      speedLimit = getPayloadValue(target.Payload, 'SpeedLimit', nan);
      routeProgress = getPayloadValue(target.Payload, 'RouteProgress', nan);
      lookaheadPoint = getPayloadValue(target.Payload, 'LookaheadPoint', nan(3, 1));
      routeRoadID = getPayloadValue(target.Payload, 'RouteRoadID', currentRoad);
      onRoad = getPayloadValue(target.Payload, 'OnRoad', false);
      currentEdgeID = getPayloadValue(target.Payload, 'CurrentEdgeID', nan);
      isOffRoad = getPayloadValue(target.Payload, 'IsOffRoad', ~logical(onRoad));
      driverProfile = getPayloadValue(target.Payload, 'DriverProfile', "");
      groundAction = getPayloadValue(target.Payload, 'GroundAction', decision);

      target.History = appendHistoryScalar(target.History, 'CurrentRoad', currentRoad);
      target.History = appendHistoryScalar(target.History, 'CurrentEdgeID', currentEdgeID);
      target.History = appendHistoryRow(target.History, 'Waypoint', currentWaypoint(:).');
      target.History = appendHistoryScalar(target.History, 'Decision', string(decision));
      target.History = appendHistoryScalar(target.History, 'RoadDeviation', roadDeviation);
      target.History = appendHistoryScalar(target.History, 'RoadID', currentRoad);
      target.History = appendHistoryScalar(target.History, 'SpeedLimit', speedLimit);
      target.History = appendHistoryScalar(target.History, 'RouteProgress', routeProgress);
      target.History = appendHistoryRow(target.History, 'LookaheadPoint', lookaheadPoint(:).');
      target.History = appendHistoryScalar(target.History, 'RouteRoadID', routeRoadID);
      target.History = appendHistoryScalar(target.History, 'OnRoad', logical(onRoad));
      target.History = appendHistoryScalar(target.History, 'IsOffRoad', logical(isOffRoad));
      target.History = appendHistoryScalar(target.History, 'DriverProfile', string(driverProfile));
      target.History = appendHistoryScalar(target.History, 'GroundAction', string(groundAction));
  else
      target.History = appendHistoryScalar(target.History, 'CurrentRoad', nan);
      target.History = appendHistoryScalar(target.History, 'CurrentEdgeID', nan);
      target.History = appendHistoryRow(target.History, 'Waypoint', nan(1, 3));
      target.History = appendHistoryScalar(target.History, 'Decision', "");
      target.History = appendHistoryScalar(target.History, 'RoadDeviation', nan);
      target.History = appendHistoryScalar(target.History, 'RoadID', nan);
      target.History = appendHistoryScalar(target.History, 'SpeedLimit', nan);
      target.History = appendHistoryScalar(target.History, 'RouteProgress', nan);
      target.History = appendHistoryRow(target.History, 'LookaheadPoint', nan(1, 3));
      target.History = appendHistoryScalar(target.History, 'RouteRoadID', nan);
      target.History = appendHistoryScalar(target.History, 'OnRoad', false);
      target.History = appendHistoryScalar(target.History, 'IsOffRoad', false);
      target.History = appendHistoryScalar(target.History, 'DriverProfile', "");
      target.History = appendHistoryScalar(target.History, 'GroundAction', "");
  end

  if target.Class == "air" && ismember(target.Subtype, ["quadcopter", "fixedWingUAV"])
      wpIdx = getPayloadValue(target.Payload, 'CurrentWaypointIndex', nan);
      distWp = getPayloadValue(target.Payload, 'DistanceToWaypoint', nan);
      missionDone = getPayloadValue(target.Payload, 'MissionComplete', false);
      previousDistWp = getPayloadValue(target.Payload, 'PreviousDistanceToWaypoint', nan);
      noProgressTime = getPayloadValue(target.Payload, 'NoProgressTime', nan);
      forceDirect = getPayloadValue(target.Payload, 'ForceDirectToWaypoint', false);
      totalXYExcursion = getPayloadValue(target.Payload, 'TotalXYExcursion', nan);
      maxAltitude = getPayloadValue(target.Payload, 'MaxAltitudeReached', nan);
      minAltitude = getPayloadValue(target.Payload, 'MinAltitudeReached', nan);
      navEvent = getPayloadValue(target.Payload, 'LastNavigationEvent', "");
      target.History = appendHistoryScalar(target.History, 'WaypointIndex', wpIdx);
      target.History = appendHistoryScalar(target.History, 'DistanceToWaypoint', distWp);
      target.History = appendHistoryScalar(target.History, 'MissionComplete', logical(missionDone));
      target.History = appendHistoryScalar(target.History, 'PreviousDistanceToWaypoint', previousDistWp);
      target.History = appendHistoryScalar(target.History, 'NoProgressTime', noProgressTime);
      target.History = appendHistoryScalar(target.History, 'ForceDirectToWaypoint', logical(forceDirect));
      target.History = appendHistoryScalar(target.History, 'TotalXYExcursion', totalXYExcursion);
      target.History = appendHistoryScalar(target.History, 'MaxAltitudeReached', maxAltitude);
      target.History = appendHistoryScalar(target.History, 'MinAltitudeReached', minAltitude);
      target.History = appendHistoryScalar(target.History, 'LastNavigationEvent', string(navEvent));
  elseif target.Class == "ground" && target.Subtype == "vehicle"
      wpIdx = getPayloadValue(target.Payload, 'CurrentWaypointIndex', nan);
      distWp = getPayloadValue(target.Payload, 'DistanceToWaypoint', nan);
      missionDone = getPayloadValue(target.Payload, 'MissionComplete', false);
      navEvent = getPayloadValue(target.Payload, 'LastNavigationEvent', "");
      target.History = appendHistoryScalar(target.History, 'WaypointIndex', wpIdx);
      target.History = appendHistoryScalar(target.History, 'DistanceToWaypoint', distWp);
      target.History = appendHistoryScalar(target.History, 'MissionComplete', logical(missionDone));
      target.History = appendHistoryScalar(target.History, 'PreviousDistanceToWaypoint', nan);
      target.History = appendHistoryScalar(target.History, 'NoProgressTime', nan);
      target.History = appendHistoryScalar(target.History, 'ForceDirectToWaypoint', false);
      target.History = appendHistoryScalar(target.History, 'TotalXYExcursion', nan);
      target.History = appendHistoryScalar(target.History, 'MaxAltitudeReached', nan);
      target.History = appendHistoryScalar(target.History, 'MinAltitudeReached', nan);
      target.History = appendHistoryScalar(target.History, 'LastNavigationEvent', string(navEvent));
  else
      target.History = appendHistoryScalar(target.History, 'WaypointIndex', nan);
      target.History = appendHistoryScalar(target.History, 'DistanceToWaypoint', nan);
      target.History = appendHistoryScalar(target.History, 'MissionComplete', false);
      target.History = appendHistoryScalar(target.History, 'PreviousDistanceToWaypoint', nan);
      target.History = appendHistoryScalar(target.History, 'NoProgressTime', nan);
      target.History = appendHistoryScalar(target.History, 'ForceDirectToWaypoint', false);
      target.History = appendHistoryScalar(target.History, 'TotalXYExcursion', nan);
      target.History = appendHistoryScalar(target.History, 'MaxAltitudeReached', nan);
      target.History = appendHistoryScalar(target.History, 'MinAltitudeReached', nan);
      target.History = appendHistoryScalar(target.History, 'LastNavigationEvent', "");
  end

  if target.Class == "air" && target.Subtype == "fixedWingUAV"
      target.History = appendHistoryScalar(target.History, 'CurrentHeading', ...
          getPayloadValue(target.Payload, 'CurrentHeading', nan));
      target.History = appendHistoryScalar(target.History, 'TargetHeading', ...
          getPayloadValue(target.Payload, 'TargetHeading', nan));
      target.History = appendHistoryScalar(target.History, 'LoiterRadius', ...
          getPayloadValue(target.Payload, 'LoiterRadius', nan));
      target.History = appendHistoryScalar(target.History, 'DiveTargetAltitude', ...
          getPayloadValue(target.Payload, 'DiveTargetAltitude', nan));
      target.History = appendHistoryScalar(target.History, 'FlightLevel', ...
          getPayloadValue(target.Payload, 'FlightLevel', nan));
      target.History = appendHistoryScalar(target.History, 'TargetFlightLevel', ...
          getPayloadValue(target.Payload, 'TargetFlightLevel', nan));
      target.History = appendHistoryScalar(target.History, 'AltitudeError', ...
          getPayloadValue(target.Payload, 'AltitudeError', nan));
      target.History = appendHistoryScalar(target.History, 'DesiredClimbRate', ...
          getPayloadValue(target.Payload, 'DesiredClimbRate', nan));
      target.History = appendHistoryScalar(target.History, 'ClimbAngleDeg', ...
          getPayloadValue(target.Payload, 'ClimbAngleDeg', nan));
      target.History = appendHistoryScalar(target.History, 'TurnSeverity', ...
          getPayloadValue(target.Payload, 'TurnSeverity', nan));
      lookaheadPoint = getPayloadValue(target.Payload, 'NavigationLookaheadPoint', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'NavigationLookaheadPoint', lookaheadPoint(:).');
      target.History = appendHistoryScalar(target.History, 'CornerCuttingActive', ...
          logical(getPayloadValue(target.Payload, 'CornerCuttingActive', false)));
      target.History = appendHistoryScalar(target.History, 'FinalPhase', ...
          logical(getPayloadValue(target.Payload, 'FinalPhase', false)));
      target.History = appendHistoryScalar(target.History, 'FinalStrategy', ...
          string(getPayloadValue(target.Payload, 'FinalStrategy', "")));
      target.History = appendHistoryScalar(target.History, 'FinalPhaseStarted', ...
          logical(getPayloadValue(target.Payload, 'FinalPhaseStarted', false)));
      target.History = appendHistoryScalar(target.History, 'FinalMissionCompleted', ...
          logical(getPayloadValue(target.Payload, 'FinalMissionCompleted', false)));
      target.History = appendHistoryScalar(target.History, 'TimeInFinalPhase', ...
          getPayloadValue(target.Payload, 'TimeInFinalPhase', 0));
      target.History = appendHistoryScalar(target.History, 'DistanceToBoundary', ...
          getPayloadValue(target.Payload, 'DistanceToBoundary', inf));
      target.History = appendHistoryScalar(target.History, 'NearBoundary', ...
          logical(getPayloadValue(target.Payload, 'NearBoundary', false)));
      target.History = appendHistoryScalar(target.History, 'OutsideBoundary', ...
          logical(getPayloadValue(target.Payload, 'OutsideBoundary', false)));
      target.History = appendHistoryScalar(target.History, 'BoundaryRecoveryActive', ...
          logical(getPayloadValue(target.Payload, 'BoundaryRecoveryActive', false)));
      recoveryTarget = getPayloadValue(target.Payload, 'BoundaryRecoveryTarget', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'BoundaryRecoveryTarget', recoveryTarget(:).');
      target.History = appendHistoryScalar(target.History, 'LastBoundaryEvent', ...
          string(getPayloadValue(target.Payload, 'LastBoundaryEvent', "none")));
      target.History = appendHistoryScalar(target.History, 'CurrentWaypointIndex', ...
          getPayloadValue(target.Payload, 'CurrentWaypointIndex', wpIdx));
      currentWp = getPayloadValue(target.Payload, 'CurrentWaypoint', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'CurrentWaypoint', currentWp(:).');
      nextWp = getPayloadValue(target.Payload, 'NextWaypoint', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'NextWaypoint', nextWp(:).');
      navTarget = getPayloadValue(target.Payload, 'NavigationTarget', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'NavigationTarget', navTarget(:).');
      lookPt = getPayloadValue(target.Payload, 'LookaheadPoint', lookaheadPoint(:));
      target.History = appendHistoryRow(target.History, 'LookaheadPoint', lookPt(:).');
      target.History = appendHistoryScalar(target.History, 'HeadingErrorDeg', ...
          getPayloadValue(target.Payload, 'HeadingErrorDeg', nan));
      target.History = appendHistoryScalar(target.History, 'TurnRateCommandDeg', ...
          getPayloadValue(target.Payload, 'TurnRateCommandDeg', nan));
      target.History = appendHistoryScalar(target.History, 'WaypointReached', ...
          logical(getPayloadValue(target.Payload, 'WaypointReached', false)));
      target.History = appendHistoryScalar(target.History, 'LoiterActive', ...
          logical(getPayloadValue(target.Payload, 'LoiterActive', false)));
      target.History = appendHistoryScalar(target.History, 'Action', ...
          string(getPayloadValue(target.Payload, 'Action', "")));
      target.History = appendHistoryScalar(target.History, 'LastDecisionReason', ...
          string(getPayloadValue(target.Payload, 'LastDecisionReason', "")));
      rawNav = getPayloadValue(target.Payload, 'RawNavigationTarget', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'RawNavigationTarget', rawNav(:).');
      smoothNav = getPayloadValue(target.Payload, 'SmoothedNavigationTarget', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'SmoothedNavigationTarget', smoothNav(:).');
      rawLook = getPayloadValue(target.Payload, 'RawLookaheadPoint', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'RawLookaheadPoint', rawLook(:).');
      smoothLook = getPayloadValue(target.Payload, 'SmoothedLookaheadPoint', nan(3, 1));
      target.History = appendHistoryRow(target.History, 'SmoothedLookaheadPoint', smoothLook(:).');
      target.History = appendHistoryScalar(target.History, 'RawTargetHeading', ...
          getPayloadValue(target.Payload, 'RawTargetHeading', nan));
      target.History = appendHistoryScalar(target.History, 'SmoothedTargetHeading', ...
          getPayloadValue(target.Payload, 'SmoothedTargetHeading', nan));
      target.History = appendHistoryScalar(target.History, 'HeadingJumpDeg', ...
          getPayloadValue(target.Payload, 'HeadingJumpDeg', 0));
      target.History = appendHistoryScalar(target.History, 'TargetPointJump', ...
          getPayloadValue(target.Payload, 'TargetPointJump', 0));
      target.History = appendHistoryScalar(target.History, 'AntiBounceActive', ...
          logical(getPayloadValue(target.Payload, 'AntiBounceActive', false)));
      target.History = appendHistoryScalar(target.History, 'LastAntiBounceEvent', ...
          string(getPayloadValue(target.Payload, 'LastAntiBounceEvent', "none")));
      target.History = appendHistoryScalar(target.History, 'TimeOnCurrentLeg', ...
          getPayloadValue(target.Payload, 'TimeOnCurrentLeg', 0));
  else
      target.History = appendHistoryScalar(target.History, 'CurrentHeading', nan);
      target.History = appendHistoryScalar(target.History, 'TargetHeading', nan);
      target.History = appendHistoryScalar(target.History, 'LoiterRadius', nan);
      target.History = appendHistoryScalar(target.History, 'DiveTargetAltitude', nan);
      target.History = appendHistoryScalar(target.History, 'FlightLevel', nan);
      target.History = appendHistoryScalar(target.History, 'TargetFlightLevel', nan);
      target.History = appendHistoryScalar(target.History, 'AltitudeError', nan);
      target.History = appendHistoryScalar(target.History, 'DesiredClimbRate', nan);
      target.History = appendHistoryScalar(target.History, 'ClimbAngleDeg', nan);
      target.History = appendHistoryScalar(target.History, 'TurnSeverity', nan);
      target.History = appendHistoryRow(target.History, 'NavigationLookaheadPoint', nan(1, 3));
      target.History = appendHistoryScalar(target.History, 'CornerCuttingActive', false);
      target.History = appendHistoryScalar(target.History, 'FinalPhase', false);
      target.History = appendHistoryScalar(target.History, 'FinalStrategy', "");
      target.History = appendHistoryScalar(target.History, 'FinalPhaseStarted', false);
      target.History = appendHistoryScalar(target.History, 'FinalMissionCompleted', false);
      target.History = appendHistoryScalar(target.History, 'TimeInFinalPhase', 0);
      target.History = appendHistoryScalar(target.History, 'DistanceToBoundary', nan);
      target.History = appendHistoryScalar(target.History, 'NearBoundary', false);
      target.History = appendHistoryScalar(target.History, 'OutsideBoundary', false);
      target.History = appendHistoryScalar(target.History, 'BoundaryRecoveryActive', false);
      target.History = appendHistoryRow(target.History, 'BoundaryRecoveryTarget', nan(1, 3));
      target.History = appendHistoryScalar(target.History, 'LastBoundaryEvent', "");
      target.History = appendHistoryScalar(target.History, 'CurrentWaypointIndex', nan);
      target.History = appendHistoryRow(target.History, 'CurrentWaypoint', nan(1, 3));
      target.History = appendHistoryRow(target.History, 'NextWaypoint', nan(1, 3));
      target.History = appendHistoryRow(target.History, 'NavigationTarget', nan(1, 3));
      target.History = appendHistoryRow(target.History, 'LookaheadPoint', nan(1, 3));
      target.History = appendHistoryScalar(target.History, 'HeadingErrorDeg', nan);
      target.History = appendHistoryScalar(target.History, 'TurnRateCommandDeg', nan);
      target.History = appendHistoryScalar(target.History, 'WaypointReached', false);
      target.History = appendHistoryScalar(target.History, 'LoiterActive', false);
      target.History = appendHistoryScalar(target.History, 'Action', "");
      target.History = appendHistoryScalar(target.History, 'LastDecisionReason', "");
      target.History = appendHistoryRow(target.History, 'RawNavigationTarget', nan(1, 3));
      target.History = appendHistoryRow(target.History, 'SmoothedNavigationTarget', nan(1, 3));
      target.History = appendHistoryRow(target.History, 'RawLookaheadPoint', nan(1, 3));
      target.History = appendHistoryRow(target.History, 'SmoothedLookaheadPoint', nan(1, 3));
      target.History = appendHistoryScalar(target.History, 'RawTargetHeading', nan);
      target.History = appendHistoryScalar(target.History, 'SmoothedTargetHeading', nan);
      target.History = appendHistoryScalar(target.History, 'HeadingJumpDeg', nan);
      target.History = appendHistoryScalar(target.History, 'TargetPointJump', nan);
      target.History = appendHistoryScalar(target.History, 'AntiBounceActive', false);
      target.History = appendHistoryScalar(target.History, 'LastAntiBounceEvent', "");
      target.History = appendHistoryScalar(target.History, 'TimeOnCurrentLeg', nan);
  end
end
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
