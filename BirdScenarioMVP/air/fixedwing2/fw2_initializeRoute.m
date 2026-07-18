function target = fw2_initializeRoute(target, config)
% fw2_initializeRoute - Задать текущий участок по индексу маршрута и позиции.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

idx = target.Payload.RouteIndex;
routePoints = target.Payload.RoutePoints;
home = target.Payload.HomePoint(:);

if idx < 1
    idx = 1;
end
if idx > size(routePoints, 1)
    target.Payload.RouteComplete = true;
    target.Payload.CurrentLegProgress = 1;
    return;
end

if idx == 1
    legStart = home;
else
    legStart = routePoints(idx - 1, :).';
end
legEnd = routePoints(idx, :).';
legVec = legEnd - legStart;
legLen = norm(legVec(1:2));

if legLen < 1e-6
    legDir = [cos(target.Payload.CurrentHeading); sin(target.Payload.CurrentHeading); 0];
else
    legDir = legVec / legLen;
end

target.Payload.CurrentLegStart = legStart;
target.Payload.CurrentLegEnd = legEnd;
target.Payload.CurrentLegVector = legDir;
target.Payload.CurrentLegLength = legLen;
target.Payload.CurrentLegProgress = 0;
target.Payload.RouteIndex = idx;
target.Payload.RouteComplete = false;
target.Payload.TargetHeading = atan2(legDir(2), legDir(1));
end
