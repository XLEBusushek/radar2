function targetOut = addDefaultNavigationOutputFields(targetOut)
% addDefaultNavigationOutputFields - Non-air/ground navigation placeholders.
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
