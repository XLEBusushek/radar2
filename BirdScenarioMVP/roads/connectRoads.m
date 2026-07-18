function roads = connectRoads(roads, config)
% connectRoads - Добавление соединительных дорог между близкими конечными точками существующих дорог.
arguments
    roads (1, :) struct
    config (1, 1) struct
end

if numel(roads) < 2
    return;
end

connectorCount = max(2, ceil(numel(roads) / 4));
nextId = max([roads.ID]) + 1;
for c = 1:connectorCount
    [aIdx, bIdx, pa, pb] = nearestEndpointPair(roads);
    if isempty(aIdx) || isempty(bIdx)
        break;
    end
    control = makeConnectorControl(pa, pb);
    points = smoothRoadPolyline(control, config);
    connector.ID = nextId; %#ok<AGROW>
    connector.Points = points;
    connector.Length = computeRoadLength(points);
    connector.Width = mean(config.roads.secondaryRoadWidthRange);
    connector.Type = "secondary";
    connector.SpeedLimit = mean(config.roads.secondaryRoadSpeedLimitRange);
    connector.Intersections = [];
    if connector.Length >= config.roads.minRoadLength
        roads(end + 1) = connector; %#ok<AGROW>
        nextId = nextId + 1;
    else
        roads(aIdx).Points = roads(aIdx).Points;
        roads(bIdx).Points = roads(bIdx).Points;
    end
end
end

function [aIdx, bIdx, pa, pb] = nearestEndpointPair(roads)
aIdx = [];
bIdx = [];
pa = [];
pb = [];
best = inf;
for i = 1:numel(roads)
    endpointsA = [roads(i).Points(1, :); roads(i).Points(end, :)];
    for j = (i + 1):numel(roads)
        endpointsB = [roads(j).Points(1, :); roads(j).Points(end, :)];
        for a = 1:2
            for b = 1:2
                d = norm(endpointsA(a, 1:2) - endpointsB(b, 1:2));
                if d < best && d > 50
                    best = d;
                    aIdx = i;
                    bIdx = j;
                    pa = endpointsA(a, :);
                    pb = endpointsB(b, :);
                end
            end
        end
    end
end
end

function control = makeConnectorControl(pa, pb)
mid = 0.5 * (pa + pb);
delta = pb(1:2) - pa(1:2);
if norm(delta) > 1e-6
    side = [-delta(2), delta(1)] / norm(delta);
    mid(1:2) = mid(1:2) + side * (rand() - 0.5) * min(120, 0.2 * norm(delta));
end
control = [pa; mid; pb];
control(:, 3) = 0;
end
