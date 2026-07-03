function target = fw2_updateMissionState(target, config)
% fw2_updateMissionState - Leg progress and completion by projection.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

if target.Payload.RouteComplete || ismember(string(target.State), ...
        ["BoundaryRecovery", "RegenerateRoute", "Return", "Loiter"])
    return;
end

legStart = target.Payload.CurrentLegStart(:);
legEnd = target.Payload.CurrentLegEnd(:);
legXY = legEnd(1:2) - legStart(1:2);
legLenSq = dot(legXY, legXY);

if legLenSq < 1e-6
    target.Payload.CurrentLegProgress = 1;
else
    p = target.Position(1:2) - legStart(1:2);
    target.Payload.CurrentLegProgress = dot(p, legXY) / legLenSq;
end

arrivalRadius = config.fixedWing2.route.arrivalRadius;
distToEnd = norm(target.Position(1:2) - legEnd(1:2));
legComplete = target.Payload.CurrentLegProgress >= 1 || distToEnd <= arrivalRadius;

if legComplete
    target = fw2_advanceLeg(target, config);
    if target.Payload.RouteComplete && config.fixedWing2.behavior.routeRegenerateOnComplete
        target.State = "RegenerateRoute";
        target.Payload.LastFW2Event = "regenerateRoute";
        target.TimeInState = 0;
    end
end
end
