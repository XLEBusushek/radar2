function validateTarget(target, config)
% validateTarget - Validate target structure and field values.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

requiredFields = {'ID', 'Class', 'Subtype', 'Position', 'Velocity', ...
    'Acceleration', 'RCS', 'Visible', 'State', 'Mission', 'TimeInState', ...
    'CurrentTime', 'StateMatrix', 'History', 'Payload', 'Behavior'};
for i = 1:numel(requiredFields)
    if ~isfield(target, requiredFields{i})
        error('validateTarget:MissingField', ...
            'Target is missing field: %s.', requiredFields{i});
    end
end

if ~isfield(config, 'world') || ~isfield(config.world, 'size')
    error('validateTarget:MissingConfig', 'config.world.size is required.');
end

worldSize = config.world.size;

assertVector3(target.Position, 'Position');
assertVector3(target.Velocity, 'Velocity');
assertVector3(target.Acceleration, 'Acceleration');

if ~isequal(size(target.StateMatrix), [3, 2])
    error('validateTarget:InvalidStateMatrix', ...
        'StateMatrix must be 3x2.');
end

assertNoNaNInf(target.Position, 'Position');
assertNoNaNInf(target.Velocity, 'Velocity');
assertNoNaNInf(target.Acceleration, 'Acceleration');
assertNoNaNInf(target.RCS, 'RCS');
assertNoNaNInf(target.StateMatrix, 'StateMatrix');

if target.RCS <= 0
    error('validateTarget:InvalidRCS', 'RCS must be positive.');
end

validateBehavior(target.Behavior);

if target.Class == "bird"
    if ~isfield(config, 'birds') || ~isfield(config.birds, 'rcsRange')
        error('validateTarget:MissingConfig', 'config.birds.rcsRange is required.');
    end
    rcsRange = config.birds.rcsRange;
    if target.RCS < rcsRange(1) || target.RCS > rcsRange(2)
        error('validateTarget:RCSOutOfRange', ...
            'Bird RCS must be within config.birds.rcsRange.');
    end
elseif target.Class == "air" && target.Subtype == "quadcopter"
    if ~isfield(config, 'quadcopter') || ~isfield(config.quadcopter, 'rcsRange')
        error('validateTarget:MissingConfig', 'config.quadcopter.rcsRange is required.');
    end
    rcsRange = config.quadcopter.rcsRange;
    if target.RCS < rcsRange(1) || target.RCS > rcsRange(2)
        error('validateTarget:RCSOutOfRange', ...
            'Quadcopter RCS must be within config.quadcopter.rcsRange.');
    end
    maxSpeed = config.quadcopter.speedRange(2);
    if norm(target.Velocity) > maxSpeed + 1e-6
        error('validateTarget:SpeedExceeded', ...
            'Quadcopter speed exceeds config.quadcopter.speedRange.');
    end
    if ~isfield(target, 'Payload') || isempty(fieldnames(target.Payload))
        error('validateTarget:MissingPayload', 'Quadcopter must have Payload.');
    end
    if ~isfield(target, 'History') || isempty(fieldnames(target.History))
        error('validateTarget:MissingHistory', 'Quadcopter must have History.');
    end
elseif target.Class == "air" && target.Subtype == "fixedWingUAV"
    isFW2 = isfield(config, 'fixedWing2') && config.fixedWing2.enabled && ...
        isfield(target, 'Metadata') && isfield(target.Metadata, 'FW2') && target.Metadata.FW2;
    if isFW2
        fw2 = config.fixedWing2;
        rcsRange = fw2.rcsRange;
        if target.RCS < rcsRange(1) || target.RCS > rcsRange(2)
            error('validateTarget:RCSOutOfRange', ...
                'Fixed-wing2 RCS must be within config.fixedWing2.rcsRange.');
        end
        speed = norm(target.Velocity);
        if speed < fw2.speed.minSpeed - 1e-6
            error('validateTarget:SpeedBelowMinimum', ...
                'Fixed-wing2 speed must stay above config.fixedWing2.speed.minSpeed.');
        end
        if speed > fw2.speed.maxSpeed + 1e-6
            error('validateTarget:SpeedExceeded', ...
                'Fixed-wing2 speed exceeds config.fixedWing2.speed.maxSpeed.');
        end
        if abs(target.Velocity(3)) > fw2.altitudeProfile.maxVerticalSpeed + 1e-6
            error('validateTarget:VerticalSpeedExceeded', ...
                'Fixed-wing2 vertical speed exceeds limit.');
        end
        if target.Position(3) < fw2.altitudeProfile.levelRange(1) - 5 || ...
                target.Position(3) > fw2.altitudeProfile.levelRange(2) + 1e-6
            error('validateTarget:InvalidFixedWingAltitude', ...
                'Fixed-wing2 altitude must be within config.fixedWing2.altitude.range.');
        end
        forbidden = ["Hover", "Idle", "Takeoff", "Landing", "Stop", "ExitArea"];
        if ismember(string(target.State), forbidden)
            error('validateTarget:ForbiddenState', ...
                'Fixed-wing2 state %s is not allowed.', string(target.State));
        end
        fw2Fields = {'RoutePoints', 'RouteIndex', 'CurrentLegStart', 'CurrentLegEnd', ...
            'CurrentLegVector', 'CurrentLegLength', 'CurrentLegProgress', 'HomePoint', ...
            'RecoveryPoint', 'CurrentHeading', 'TargetHeading', 'HeadingErrorDeg', ...
            'TurnRateCommandDeg', 'SpeedProfileEnabled', 'BaseCruiseSpeed', 'TargetSpeed', ...
            'CurrentSpeed', 'LastSpeedChangeTime', 'NextSpeedChangeTime', 'SpeedProfileEvent', ...
            'AltitudeProfileEnabled', 'FlightLevels', 'CurrentFlightLevel', 'TargetFlightLevel', ...
            'LastAltitudeChangeTime', 'NextAltitudeChangeTime', 'AltitudeProfileEvent', ...
            'FlightLevel', 'AltitudeError', 'DesiredClimbRate', 'ClimbAngleDeg', ...
            'SafeZone', 'DistanceToBoundary', 'InWarningZone', 'InCriticalZone', ...
            'BorderFollowing', 'BorderFollowingTime', 'MissionID', 'RouteComplete', ...
            'LoiterUsed', 'LoiterCenter', 'LoiterRadius', 'LoiterStartTime', ...
            'LoiterDuration', 'LoiterDirection', 'LastFW2Event'};
        for k = 1:numel(fw2Fields)
            if ~isfield(target.Payload, fw2Fields{k})
                error('validateTarget:MissingPayloadField', ...
                    'Fixed-wing2 Payload missing field: %s.', fw2Fields{k});
            end
        end
    else
    if ~isfield(config, 'fixedWing') || ~isfield(config.fixedWing, 'rcsRange')
        error('validateTarget:MissingConfig', 'config.fixedWing.rcsRange is required.');
    end
    fw = config.fixedWing;
    rcsRange = fw.rcsRange;
    if target.RCS < rcsRange(1) || target.RCS > rcsRange(2)
        error('validateTarget:RCSOutOfRange', ...
            'Fixed-wing UAV RCS must be within config.fixedWing.rcsRange.');
    end
    speed = norm(target.Velocity);
    if speed < fw.minSpeed - 1e-6 && ~ismember(string(target.State), ...
            ["ExitArea", "ApproachExit", "AlignExit", "Exit", "LoiterEnd", "ReturnHome"])
        error('validateTarget:SpeedBelowMinimum', ...
            'Fixed-wing UAV speed must stay above config.fixedWing.minSpeed.');
    end
    if speed > fw.maxSpeed + 1e-6
        error('validateTarget:SpeedExceeded', ...
            'Fixed-wing UAV speed exceeds config.fixedWing.maxSpeed.');
    end
    if abs(target.Velocity(3)) > fw.maxVerticalSpeed + 1e-6
        error('validateTarget:VerticalSpeedExceeded', ...
            'Fixed-wing UAV vertical speed exceeds config.fixedWing.maxVerticalSpeed.');
    end
    if target.Position(3) < fw.operatingAltitudeRange(1) - 5 || ...
            target.Position(3) > fw.operatingAltitudeRange(2) + 1e-6
        error('validateTarget:InvalidFixedWingAltitude', ...
            'Fixed-wing UAV altitude must be within config.fixedWing.operatingAltitudeRange.');
    end
    requiredPayloadFields = {'HomePosition', 'ExitPoint', 'Waypoints', ...
        'CurrentWaypointIndex', 'CurrentWaypoint', 'DesiredSpeed', ...
        'DesiredVelocity', 'DesiredAltitude', 'CurrentHeading', ...
        'TargetHeading', 'DistanceToWaypoint', 'MissionComplete', ...
        'LastNavigationEvent', 'FlightLevel', 'TargetFlightLevel', ...
        'AltitudeBand', 'AltitudeError', 'DesiredClimbRate', ...
        'ClimbAngleDeg', 'TurnSeverity', 'NavigationLookaheadPoint', ...
        'CornerCuttingActive', 'FinalPhase', 'FinalStrategy', 'FinalPhaseStarted', ...
        'FinalMissionCompleted', 'TimeInFinalPhase', 'DistanceToBoundary', ...
        'NearBoundary', 'OutsideBoundary', 'BoundaryRecoveryActive', ...
        'BoundaryRecoveryTarget', 'TimeOutsideBoundary', 'LastBoundaryEvent', ...
        'NextWaypoint', 'NavigationTarget', 'LookaheadPoint', ...
        'HeadingErrorDeg', 'TurnRateCommandDeg', 'WaypointReached', ...
        'LoiterActive', 'Action', 'LastDecisionReason', ...
        'RawNavigationTarget', 'SmoothedNavigationTarget', ...
        'RawLookaheadPoint', 'SmoothedLookaheadPoint', ...
        'RawTargetHeading', 'SmoothedTargetHeading', ...
        'HeadingJumpDeg', 'TargetPointJump', 'AntiBounceActive', ...
        'LastAntiBounceEvent', 'TimeOnCurrentLeg', 'LastWaypointSwitchTime', ...
        'ActiveLegStart', 'ActiveLegEnd', 'ActiveLegIndex', 'ActiveLegProgress', ...
        'ActiveLegLength', 'ActiveLegDirection', 'PreviousLegDirection', ...
        'NextLegDirection', 'LegTransitionActive', 'LegTransitionStartTime', ...
        'LegTransitionDuration'};
    for k = 1:numel(requiredPayloadFields)
        if ~isfield(target.Payload, requiredPayloadFields{k})
            error('validateTarget:MissingPayloadField', ...
                'Fixed-wing UAV Payload is missing field: %s.', requiredPayloadFields{k});
        end
    end
    end
elseif target.Class == "ground" && target.Subtype == "vehicle"
    if ~isfield(config, 'groundVehicle') || ~isfield(config.groundVehicle, 'rcsRange')
        error('validateTarget:MissingConfig', 'config.groundVehicle.rcsRange is required.');
    end
    rcsRange = config.groundVehicle.rcsRange;
    if target.RCS < rcsRange(1) || target.RCS > rcsRange(2)
        error('validateTarget:RCSOutOfRange', ...
            'Ground vehicle RCS must be within config.groundVehicle.rcsRange.');
    end
    maxSpeed = config.groundVehicle.speedRange(2);
    if norm(target.Velocity) > maxSpeed + 1e-6
        error('validateTarget:SpeedExceeded', ...
            'Ground vehicle speed exceeds config.groundVehicle.speedRange.');
    end
    heightRange = config.groundVehicle.heightRange;
    if target.Position(3) < heightRange(1) - 1e-6 || target.Position(3) > heightRange(2) + 1e-6
        error('validateTarget:InvalidGroundHeight', ...
            'Ground vehicle height must be within config.groundVehicle.heightRange.');
    end
    requiredPayloadFields = {'CurrentRoadID', 'CurrentWaypointIndex', ...
        'CurrentWaypoint', 'DesiredSpeed', 'DesiredVelocity', 'RoadDeviation', ...
        'Route', 'RoadRoute', 'RoutePoints', 'RouteProgress', 'LookaheadPoint', ...
        'OnRoad', 'CurrentEdgeID', 'IsOffRoad', 'DriverProfile', 'GroundAction'};
    for k = 1:numel(requiredPayloadFields)
        if ~isfield(target.Payload, requiredPayloadFields{k})
            error('validateTarget:MissingPayloadField', ...
                'Ground vehicle Payload is missing field: %s.', requiredPayloadFields{k});
        end
    end
end

allowOutOfBounds = target.Class == "air" && target.Subtype == "fixedWingUAV" && ...
    isfield(config, 'fixedWing') && isfield(config.fixedWing, 'allowExitArea') && config.fixedWing.allowExitArea && ...
    isfield(target.Payload, 'FinalPhaseStarted') && target.Payload.FinalPhaseStarted && ...
    string(target.State) == "Exit";
if ~allowOutOfBounds
    if target.Position(1) < 0 || target.Position(1) > worldSize(1) || ...
            target.Position(2) < 0 || target.Position(2) > worldSize(2)
        error('validateTarget:OutOfBounds', ...
            'Target position must be inside the world bounds.');
    end
end
if target.Position(3) < 0 || target.Position(3) > worldSize(3)
    error('validateTarget:OutOfBounds', ...
        'Target position must be inside the world bounds.');
end
end

function validateBehavior(behavior)
requiredBehaviorFields = {'Enabled', 'Profile', 'Personality', 'Memory', ...
    'CurrentGoal', 'LastDecision', 'LastDecisionTime', 'NextDecisionTime', ...
    'DecisionPeriod', 'DecisionHistory', 'LastWeights', 'LastContext'};
for j = 1:numel(requiredBehaviorFields)
    if ~isfield(behavior, requiredBehaviorFields{j})
        error('validateTarget:MissingBehaviorField', ...
            'Behavior is missing field: %s.', requiredBehaviorFields{j});
    end
end

requiredPersonalityFields = {'Randomness', 'MissionFocus', 'Curiosity', ...
    'Caution', 'SpeedBias', 'AltitudeBias', 'HoverBias', 'ScanBias', ...
    'ReturnBias', 'ManeuverBias', 'DriverAggression', 'PatrolProbability', ...
    'StopProbability', 'LeaveRoadProbability', 'RoadDiscipline', 'Attention'};
for j = 1:numel(requiredPersonalityFields)
    fieldName = requiredPersonalityFields{j};
    if ~isfield(behavior.Personality, fieldName)
        error('validateTarget:MissingPersonalityField', ...
            'Behavior.Personality is missing field: %s.', fieldName);
    end
    value = behavior.Personality.(fieldName);
    if value < 0.5 || value > 1.5 || isnan(value) || isinf(value)
        error('validateTarget:InvalidPersonality', ...
            'Behavior.Personality.%s must be in [0.5, 1.5].', fieldName);
    end
end
end

function assertVector3(v, fieldName)
if ~isequal(size(v), [3, 1])
    error('validateTarget:InvalidSize', '%s must be 3x1.', fieldName);
end
end

function assertNoNaNInf(v, fieldName)
if any(isnan(v(:))) || any(isinf(v(:)))
    error('validateTarget:InvalidValue', ...
        '%s must not contain NaN or Inf.', fieldName);
end
end
