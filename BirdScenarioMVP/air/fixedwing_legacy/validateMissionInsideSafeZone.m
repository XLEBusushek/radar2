function valid = validateMissionInsideSafeZone(mission, config)
% validateMissionInsideSafeZone - Проверить, что все точки маршрута лежат в Safe Zone.
arguments
    mission (1, 1) struct
    config (1, 1) struct
end

valid = true;
if ~isfield(mission, 'Waypoints') || isempty(mission.Waypoints)
    return;
end

for i = 1:size(mission.Waypoints, 1)
    if ~isWaypointInsideSafeZone(mission.Waypoints(i, :).', config)
        valid = false;
        return;
    end
end
end
