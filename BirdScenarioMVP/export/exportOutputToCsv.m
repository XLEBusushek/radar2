function exportOutputToCsv(output, config, outputFolder)
% exportOutputToCsv - Export simulation output to a CSV track table.
arguments
    output struct
    config (1, 1) struct
    outputFolder (1, :) char
end

rows = buildOutputTableRows(output);
T = struct2table(rows);
csvPath = fullfile(outputFolder, config.export.csvFileName);
writetable(T, csvPath);
end

function rows = buildOutputTableRows(output)
rows = struct( ...
    'Time', {}, 'RandomMode', {}, 'ScenarioSeed', {}, ...
    'ID', {}, 'Class', {}, 'Subtype', {}, 'TargetSeed', {}, ...
    'X', {}, 'Y', {}, 'Z', {}, ...
    'Vx', {}, 'Vy', {}, 'Vz', {}, ...
    'RCS', {}, 'Visible', {}, 'State', {}, 'Mission', {}, ...
    'CurrentTreeID', {}, 'TargetTreeID', {}, ...
    'TransitionCount', {}, 'TransitionReason', {}, ...
    'WaypointIndex', {}, 'DistanceToWaypoint', {}, 'MissionComplete', {}, ...
    'NoProgressTime', {}, 'ForceDirectToWaypoint', {}, ...
    'TotalXYExcursion', {}, 'MaxAltitudeReached', {}, 'MinAltitudeReached', {}, ...
    'LastNavigationEvent', {}, ...
    'RoadID', {}, 'CurrentEdgeID', {}, 'Waypoint', {}, 'SpeedLimit', {}, 'RoadDeviation', {}, ...
    'RouteProgress', {}, 'OnRoad', {}, 'IsOffRoad', {}, 'DriverProfile', {}, 'GroundAction', {}, ...
    'DesiredSpeed', {}, 'DesiredAltitude', {}, 'CurrentHeading', {}, ...
    'TargetHeading', {}, 'LoiterRadius', {}, 'DiveTargetAltitude', {}, ...
    'FlightLevel', {}, 'TargetFlightLevel', {}, 'AltitudeError', {}, ...
    'DesiredClimbRate', {}, 'ClimbAngleDeg', {}, 'TurnSeverity', {}, ...
    'CornerCuttingActive', {}, ...
    'FinalPhase', {}, 'FinalStrategy', {}, 'FinalPhaseStarted', {}, ...
    'FinalMissionCompleted', {}, 'TimeInFinalPhase', {}, ...
    'DistanceToBoundary', {}, 'NearBoundary', {}, 'OutsideBoundary', {}, ...
    'BoundaryRecoveryActive', {}, 'LastBoundaryEvent', {}, ...
    'HeadingJumpDeg', {}, 'TargetPointJump', {}, 'AntiBounceActive', {}, ...
    'LastAntiBounceEvent', {}, 'TimeOnCurrentLeg', {}, ...
    'Decision', {}, ...
    'BehaviorAction', {}, 'BehaviorReason', {}, 'BehaviorGoal', {}, ...
    'BehaviorProfile', {}, ...
    'RouteIndex', {}, 'CurrentLegProgress', {}, 'BaseCruiseSpeed', {}, ...
    'CurrentSpeed', {}, 'TargetSpeed', {}, 'SpeedProfileEvent', {}, ...
    'CurrentFlightLevel', {}, 'HeadingErrorDeg', {}, 'TurnRateCommandDeg', {}, ...
    'AltitudeProfileEvent', {}, ...
    'InWarningZone', {}, 'InCriticalZone', {}, 'BorderFollowing', {}, ...
    'LastFW2Event', {});

if isempty(output)
    return;
end

rowIdx = 0;
for k = 1:numel(output)
    step = output(k);
    if ~isfield(step, 'Targets') || isempty(step.Targets)
        continue;
    end

    for i = 1:numel(step.Targets)
        target = step.Targets(i);
        rowIdx = rowIdx + 1;

        pos = target.Position(:);
        vel = target.Velocity(:);

        rows(rowIdx).Time = step.Time;
        rows(rowIdx).RandomMode = string(getStepStringField(step, 'RandomMode'));
        rows(rowIdx).ScenarioSeed = getStepNumericField(step, 'ScenarioSeed');
        rows(rowIdx).ID = target.ID;
        rows(rowIdx).Class = string(target.Class);
        rows(rowIdx).Subtype = string(target.Subtype);
        rows(rowIdx).TargetSeed = getTargetSeed(target);
        rows(rowIdx).X = pos(1);
        rows(rowIdx).Y = pos(2);
        rows(rowIdx).Z = pos(3);
        rows(rowIdx).Vx = vel(1);
        rows(rowIdx).Vy = vel(2);
        rows(rowIdx).Vz = vel(3);
        rows(rowIdx).RCS = target.RCS;
        rows(rowIdx).Visible = logical(target.Visible);
        rows(rowIdx).State = string(target.State);
        rows(rowIdx).Mission = string(target.Mission);
        rows(rowIdx).CurrentTreeID = getOptionalNumericField(target, 'CurrentTreeID');
        rows(rowIdx).TargetTreeID = getOptionalNumericField(target, 'TargetTreeID');
        rows(rowIdx).TransitionCount = getOptionalNumericField(target, 'TransitionCount', 0);
        rows(rowIdx).TransitionReason = string(getOptionalStringField(target, 'TransitionReason'));
        rows(rowIdx).WaypointIndex = getOptionalNumericField(target, 'WaypointIndex');
        rows(rowIdx).DistanceToWaypoint = getOptionalNumericField(target, 'DistanceToWaypoint');
        rows(rowIdx).MissionComplete = getOptionalLogicalField(target, 'MissionComplete', false);
        rows(rowIdx).NoProgressTime = getOptionalNumericField(target, 'NoProgressTime');
        rows(rowIdx).ForceDirectToWaypoint = getOptionalLogicalField(target, 'ForceDirectToWaypoint', false);
        rows(rowIdx).TotalXYExcursion = getOptionalNumericField(target, 'TotalXYExcursion');
        rows(rowIdx).MaxAltitudeReached = getOptionalNumericField(target, 'MaxAltitudeReached');
        rows(rowIdx).MinAltitudeReached = getOptionalNumericField(target, 'MinAltitudeReached');
        rows(rowIdx).LastNavigationEvent = string(getOptionalStringField(target, 'LastNavigationEvent'));
        rows(rowIdx).RoadID = getOptionalNumericField(target, 'RoadID');
        rows(rowIdx).CurrentEdgeID = getOptionalNumericField(target, 'CurrentEdgeID');
        rows(rowIdx).Waypoint = serializeVectorField(target, 'Waypoint');
        rows(rowIdx).SpeedLimit = getOptionalNumericField(target, 'SpeedLimit');
        rows(rowIdx).RoadDeviation = getOptionalNumericField(target, 'RoadDeviation');
        rows(rowIdx).RouteProgress = getOptionalNumericField(target, 'RouteProgress');
        rows(rowIdx).OnRoad = getOptionalLogicalField(target, 'OnRoad', false);
        rows(rowIdx).IsOffRoad = getOptionalLogicalField(target, 'IsOffRoad', false);
        rows(rowIdx).DriverProfile = string(getOptionalStringField(target, 'DriverProfile'));
        rows(rowIdx).GroundAction = string(getOptionalStringField(target, 'GroundAction'));
        rows(rowIdx).DesiredSpeed = getOptionalNumericField(target, 'DesiredSpeed', 0);
        rows(rowIdx).DesiredAltitude = getOptionalNumericField(target, 'DesiredAltitude');
        rows(rowIdx).CurrentHeading = getOptionalNumericField(target, 'CurrentHeading');
        rows(rowIdx).TargetHeading = getOptionalNumericField(target, 'TargetHeading');
        rows(rowIdx).LoiterRadius = getOptionalNumericField(target, 'LoiterRadius');
        rows(rowIdx).DiveTargetAltitude = getOptionalNumericField(target, 'DiveTargetAltitude');
        rows(rowIdx).FlightLevel = getOptionalNumericField(target, 'FlightLevel');
        rows(rowIdx).TargetFlightLevel = getOptionalNumericField(target, 'TargetFlightLevel');
        rows(rowIdx).AltitudeError = getOptionalNumericField(target, 'AltitudeError');
        rows(rowIdx).DesiredClimbRate = getOptionalNumericField(target, 'DesiredClimbRate');
        rows(rowIdx).ClimbAngleDeg = getOptionalNumericField(target, 'ClimbAngleDeg');
        rows(rowIdx).TurnSeverity = getOptionalNumericField(target, 'TurnSeverity');
        rows(rowIdx).CornerCuttingActive = getOptionalLogicalField(target, 'CornerCuttingActive', false);
        rows(rowIdx).FinalPhase = getOptionalLogicalField(target, 'FinalPhase', false);
        rows(rowIdx).FinalStrategy = string(getOptionalStringField(target, 'FinalStrategy'));
        rows(rowIdx).FinalPhaseStarted = getOptionalLogicalField(target, 'FinalPhaseStarted', false);
        rows(rowIdx).FinalMissionCompleted = getOptionalLogicalField(target, 'FinalMissionCompleted', false);
        rows(rowIdx).TimeInFinalPhase = getOptionalNumericField(target, 'TimeInFinalPhase', 0);
        rows(rowIdx).DistanceToBoundary = getOptionalNumericField(target, 'DistanceToBoundary');
        rows(rowIdx).NearBoundary = getOptionalLogicalField(target, 'NearBoundary', false);
        rows(rowIdx).OutsideBoundary = getOptionalLogicalField(target, 'OutsideBoundary', false);
        rows(rowIdx).BoundaryRecoveryActive = getOptionalLogicalField(target, 'BoundaryRecoveryActive', false);
        rows(rowIdx).LastBoundaryEvent = string(getOptionalStringField(target, 'LastBoundaryEvent'));
        rows(rowIdx).HeadingJumpDeg = getOptionalNumericField(target, 'HeadingJumpDeg', 0);
        rows(rowIdx).TargetPointJump = getOptionalNumericField(target, 'TargetPointJump', 0);
        rows(rowIdx).AntiBounceActive = getOptionalLogicalField(target, 'AntiBounceActive', false);
        rows(rowIdx).LastAntiBounceEvent = string(getOptionalStringField(target, 'LastAntiBounceEvent'));
        rows(rowIdx).TimeOnCurrentLeg = getOptionalNumericField(target, 'TimeOnCurrentLeg', 0);
        rows(rowIdx).Decision = string(getOptionalStringField(target, 'Decision'));
        rows(rowIdx).BehaviorAction = string(getOptionalStringField(target, 'BehaviorAction'));
        rows(rowIdx).BehaviorReason = string(getOptionalStringField(target, 'BehaviorReason'));
        rows(rowIdx).BehaviorGoal = string(getOptionalStringField(target, 'BehaviorGoal'));
        rows(rowIdx).BehaviorProfile = string(getOptionalStringField(target, 'BehaviorProfile'));
        rows(rowIdx).RouteIndex = getOptionalNumericField(target, 'RouteIndex');
        rows(rowIdx).CurrentLegProgress = getOptionalNumericField(target, 'CurrentLegProgress');
        rows(rowIdx).BaseCruiseSpeed = getOptionalNumericField(target, 'BaseCruiseSpeed');
        rows(rowIdx).CurrentSpeed = getOptionalNumericField(target, 'CurrentSpeed');
        rows(rowIdx).TargetSpeed = getOptionalNumericField(target, 'TargetSpeed');
        rows(rowIdx).SpeedProfileEvent = string(getOptionalStringField(target, 'SpeedProfileEvent'));
        rows(rowIdx).CurrentFlightLevel = getOptionalNumericField(target, 'CurrentFlightLevel');
        rows(rowIdx).HeadingErrorDeg = getOptionalNumericField(target, 'HeadingErrorDeg');
        rows(rowIdx).TurnRateCommandDeg = getOptionalNumericField(target, 'TurnRateCommandDeg');
        rows(rowIdx).AltitudeProfileEvent = string(getOptionalStringField(target, 'AltitudeProfileEvent'));
        rows(rowIdx).InWarningZone = getOptionalLogicalField(target, 'InWarningZone', false);
        rows(rowIdx).InCriticalZone = getOptionalLogicalField(target, 'InCriticalZone', false);
        rows(rowIdx).BorderFollowing = getOptionalLogicalField(target, 'BorderFollowing', false);
        rows(rowIdx).LastFW2Event = string(getOptionalStringField(target, 'LastFW2Event'));
    end
end
end

function value = serializeVectorField(target, fieldName)
if isfield(target, fieldName) && ~isempty(target.(fieldName))
    v = target.(fieldName);
    value = sprintf('%.3f %.3f %.3f', v(1), v(2), v(3));
else
    value = "";
end
end

function value = getStepNumericField(step, fieldName)
if isfield(step, fieldName) && ~isempty(step.(fieldName))
    value = step.(fieldName);
else
    value = NaN;
end
end

function value = getStepStringField(step, fieldName)
if isfield(step, fieldName) && ~isempty(step.(fieldName))
    value = step.(fieldName);
else
    value = "";
end
end

function value = getOptionalNumericField(target, fieldName, defaultValue)
if nargin < 3
    defaultValue = NaN;
end
if isfield(target, fieldName) && ~isempty(target.(fieldName))
    value = target.(fieldName);
else
    value = defaultValue;
end
end

function value = getTargetSeed(target)
if isfield(target, 'TargetSeed') && ~isempty(target.TargetSeed)
    value = target.TargetSeed;
else
    value = getOptionalNumericField(target, 'RandomSeed');
end
end

function value = getOptionalStringField(target, fieldName)
if isfield(target, fieldName) && ~isempty(target.(fieldName))
    value = target.(fieldName);
else
    value = "";
end
end

function value = getOptionalLogicalField(target, fieldName, defaultValue)
if isfield(target, fieldName) && ~isempty(target.(fieldName))
    value = logical(target.(fieldName));
else
    value = logical(defaultValue);
end
end
