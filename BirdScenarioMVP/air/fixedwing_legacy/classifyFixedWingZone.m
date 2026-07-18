function zoneInfo = classifyFixedWingZone(position, config)
% classifyFixedWingZone - Классифицировать позицию относительно зон полёта.
arguments
    position (3, 1) double
    config (1, 1) struct
end

worldSize = config.world.size;
[distanceToBoundary, outside] = computeDistanceToWorldBoundary(position, worldSize);
zones = getFixedWingZoneBounds(config);

zoneInfo.DistanceToBoundary = distanceToBoundary;
zoneInfo.OutsideBoundary = outside;
zoneInfo.InSafeZone = distanceToBoundary >= zones.SafeMargin;
zoneInfo.InWarningZone = distanceToBoundary >= zones.CriticalInner && ...
    distanceToBoundary < zones.SafeMargin;
zoneInfo.InCriticalZone = ~outside && distanceToBoundary >= 0 && ...
    distanceToBoundary < zones.CriticalInner;
zoneInfo.SafeZone = zones.SafeZone;
zoneInfo.WarningZone = zones.WarningZone;
zoneInfo.CriticalZone = zones.CriticalZone;
zoneInfo.World = zones.World;

[zoneInfo.BorderSide, zoneInfo.NearestEdgeDistance] = nearestBorderSide(position, worldSize);
end

function [side, dist] = nearestBorderSide(position, worldSize)
pos = position(:);
distances = [pos(1), worldSize(1) - pos(1), pos(2), worldSize(2) - pos(2)];
[dist, idx] = min(distances);
sides = ["left", "right", "bottom", "top"];
side = sides(idx);
end
