function targetOut = addGroundOutputFields(targetOut, target)
% addGroundOutputFields - Выходные поля наземного транспортного средства.
payload = target.Payload;

targetOut.WaypointIndex = getPayloadField(payload, 'CurrentWaypointIndex', nan);
targetOut.DistanceToWaypoint = getPayloadField(payload, 'DistanceToWaypoint', nan);
targetOut.MissionComplete = getPayloadField(payload, 'MissionComplete', false);
targetOut.HomePosition = getPayloadField(payload, 'HomePosition', nan(3, 1));
targetOut.CurrentWaypoint = getPayloadField(payload, 'CurrentWaypoint', nan(3, 1));
targetOut.NoProgressTime = nan;
targetOut.ForceDirectToWaypoint = false;
targetOut.TotalXYExcursion = nan;
targetOut.MaxAltitudeReached = nan;
targetOut.MinAltitudeReached = nan;
targetOut.LastNavigationEvent = string(getPayloadField(payload, 'LastNavigationEvent', ""));
targetOut.RoadID = getPayloadField(payload, 'CurrentRoadID', nan);
targetOut.CurrentEdgeID = getPayloadField(payload, 'CurrentEdgeID', nan);
targetOut.CurrentRoad = targetOut.RoadID;
targetOut.Waypoint = targetOut.CurrentWaypoint;
targetOut.SpeedLimit = getPayloadField(payload, 'SpeedLimit', nan);
targetOut.RoadDeviation = getPayloadField(payload, 'RoadDeviation', nan);
targetOut.RouteProgress = getPayloadField(payload, 'RouteProgress', nan);
targetOut.LookaheadPoint = getPayloadField(payload, 'LookaheadPoint', nan(3, 1));
targetOut.RouteRoadID = getPayloadField(payload, 'RouteRoadID', targetOut.RoadID);
targetOut.OnRoad = getPayloadField(payload, 'OnRoad', false);
targetOut.IsOffRoad = getPayloadField(payload, 'IsOffRoad', ~targetOut.OnRoad);
targetOut.DriverProfile = string(getPayloadField(payload, 'DriverProfile', ""));
targetOut.GroundAction = string(getPayloadField(payload, 'GroundAction', targetOut.Decision));
targetOut.Decision = string(getPayloadField(payload, 'LastDecision', ""));
end
