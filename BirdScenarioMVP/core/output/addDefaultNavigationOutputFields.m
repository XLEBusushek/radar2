function targetOut = addDefaultNavigationOutputFields(targetOut)
% addDefaultNavigationOutputFields - Заглушки навигации для не-воздушных/наземных целей.
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
