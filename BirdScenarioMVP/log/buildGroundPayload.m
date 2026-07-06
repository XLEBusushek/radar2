function payload = buildGroundPayload(target)
% buildGroundPayload - Ground vehicle payload snapshot.
payload = struct();
if ~isfield(target, 'Payload')
    return;
end
p = target.Payload;
fields = {'CurrentRoadID', 'CurrentEdgeID', 'CurrentWaypointIndex', ...
    'DistanceToWaypoint', 'MissionComplete', 'HomePosition', 'CurrentWaypoint', ...
    'SpeedLimit', 'RoadDeviation', 'RouteProgress', 'LookaheadPoint', 'RouteRoadID', ...
    'OnRoad', 'IsOffRoad', 'DriverProfile', 'GroundAction', 'LastDecision', ...
    'LastNavigationEvent', 'RoutePoints'};
for i = 1:numel(fields)
    if isfield(p, fields{i})
        payload.(fields{i}) = p.(fields{i});
    end
end
end
