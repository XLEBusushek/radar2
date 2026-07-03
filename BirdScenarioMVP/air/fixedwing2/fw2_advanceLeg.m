function target = fw2_advanceLeg(target, config)
% fw2_advanceLeg - Move to next route leg or mark route complete.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

if target.Payload.RouteComplete
    return;
end

target.Payload.RouteIndex = target.Payload.RouteIndex + 1;
if target.Payload.RouteIndex > size(target.Payload.RoutePoints, 1)
    target.Payload.RouteComplete = true;
    target.Payload.CurrentLegProgress = 1;
    target.Payload.LastFW2Event = "routeComplete";
    return;
end

target = fw2_initializeRoute(target, config);
target.Payload.LastFW2Event = "legAdvanced";
end
