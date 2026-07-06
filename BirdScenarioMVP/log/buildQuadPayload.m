function payload = buildQuadPayload(target)
% buildQuadPayload - Quadcopter-specific payload snapshot.
payload = struct();
if ~isfield(target, 'Payload')
    return;
end
p = target.Payload;
fields = {'CurrentWaypointIndex', 'DistanceToWaypoint', 'MissionComplete', ...
    'HomePosition', 'CurrentWaypoint', 'NoProgressTime', 'ForceDirectToWaypoint', ...
    'TotalXYExcursion', 'MaxAltitudeReached', 'MinAltitudeReached', 'LastNavigationEvent'};
for i = 1:numel(fields)
    if isfield(p, fields{i})
        payload.(fields{i}) = p.(fields{i});
    end
end
end
