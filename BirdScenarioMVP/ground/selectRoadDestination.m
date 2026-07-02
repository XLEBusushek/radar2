function sample = selectRoadDestination(roadNetwork, config, previousPoint, preferredRoadId)
% selectRoadDestination - Pick a road waypoint at a reasonable route distance.
arguments
    roadNetwork (1, 1) struct
    config (1, 1) struct
    previousPoint (3, 1) double
    preferredRoadId (1, 1) double = nan
end

nav = config.groundVehicle.navigation;
maxAttempts = 40;
sample = sampleRoadPoint(roadNetwork, preferredRoadId);

for attempt = 1:maxAttempts
    if attempt <= round(maxAttempts * 0.45) && ~isnan(preferredRoadId)
        candidate = sampleRoadPoint(roadNetwork, preferredRoadId);
    else
        candidate = sampleRoadPoint(roadNetwork);
    end
    dist = norm(candidate.Position(1:2) - previousPoint(1:2));
    if dist >= nav.minWaypointDistance && dist <= nav.maxWaypointDistance
        sample = candidate;
        return;
    end
    sample = candidate;
end
end
