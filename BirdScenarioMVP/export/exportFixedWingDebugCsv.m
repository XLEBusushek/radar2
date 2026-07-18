function exportFixedWingDebugCsv(output, config, outputFolder)
% exportFixedWingDebugCsv - Экспорт отладочного CSV навигации fixed-wing.
arguments
    output struct
    config (1, 1) struct
    outputFolder (1, :) char
end

rows = buildFixedWingDebugRows(output);
if isempty(rows)
    return;
end

T = struct2table(rows);
fileName = "fixed_wing_debug.csv";
if isfield(config, 'export') && isfield(config.export, 'fixedWingDebugCsvFileName')
    fileName = config.export.fixedWingDebugCsvFileName;
end
csvPath = fullfile(outputFolder, fileName);
writetable(T, csvPath);
end

function rows = buildFixedWingDebugRows(output)
rows = struct( ...
    'Time', {}, 'ID', {}, 'State', {}, 'Action', {}, ...
    'CurrentWaypointIndex', {}, 'X', {}, 'Y', {}, 'Z', {}, ...
    'Vx', {}, 'Vy', {}, 'Vz', {}, ...
    'CurrentHeading', {}, 'TargetHeading', {}, ...
    'HeadingErrorDeg', {}, 'TurnRateCommandDeg', {}, ...
    'DistanceToWaypoint', {}, 'WaypointReached', {}, ...
    'BoundaryRecoveryActive', {}, 'FinalPhaseStarted', {}, ...
    'LoiterActive', {}, 'LastDecisionReason', {});

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
        if string(target.Subtype) ~= "fixedWingUAV"
            continue;
        end

        rowIdx = rowIdx + 1;
        pos = target.Position(:);
        vel = target.Velocity(:);

        rows(rowIdx).Time = step.Time;
        rows(rowIdx).ID = target.ID;
        rows(rowIdx).State = string(target.State);
        rows(rowIdx).Action = string(getOptionalStringField(target, 'Action'));
        rows(rowIdx).CurrentWaypointIndex = getOptionalNumericField(target, 'CurrentWaypointIndex', ...
            getOptionalNumericField(target, 'WaypointIndex'));
        rows(rowIdx).X = pos(1);
        rows(rowIdx).Y = pos(2);
        rows(rowIdx).Z = pos(3);
        rows(rowIdx).Vx = vel(1);
        rows(rowIdx).Vy = vel(2);
        rows(rowIdx).Vz = vel(3);
        rows(rowIdx).CurrentHeading = getOptionalNumericField(target, 'CurrentHeading');
        rows(rowIdx).TargetHeading = getOptionalNumericField(target, 'TargetHeading');
        rows(rowIdx).HeadingErrorDeg = getOptionalNumericField(target, 'HeadingErrorDeg');
        rows(rowIdx).TurnRateCommandDeg = getOptionalNumericField(target, 'TurnRateCommandDeg');
        rows(rowIdx).DistanceToWaypoint = getOptionalNumericField(target, 'DistanceToWaypoint');
        rows(rowIdx).WaypointReached = getOptionalLogicalField(target, 'WaypointReached', false);
        rows(rowIdx).BoundaryRecoveryActive = getOptionalLogicalField(target, 'BoundaryRecoveryActive', false);
        rows(rowIdx).FinalPhaseStarted = getOptionalLogicalField(target, 'FinalPhaseStarted', false);
        rows(rowIdx).LoiterActive = getOptionalLogicalField(target, 'LoiterActive', false);
        rows(rowIdx).LastDecisionReason = string(getOptionalStringField(target, 'LastDecisionReason'));
    end
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
