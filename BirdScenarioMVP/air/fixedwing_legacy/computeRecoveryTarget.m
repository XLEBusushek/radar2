function recoveryTarget = computeRecoveryTarget(target, config, reason)
% computeRecoveryTarget - Выбрать стабильную внутреннюю точку глубоко в Safe Zone.
arguments
    target (1, 1) struct
    config (1, 1) struct
    reason (1, 1) string = "warningZone"
end

worldSize = config.world.size;
zoneCfg = config.fixedWing.zones;
zones = getFixedWingZoneBounds(config);
safe = zones.SafeZone;
pos = target.Position(:);
heading = target.Payload.CurrentHeading;
if isnan(heading)
    heading = atan2(target.Velocity(2), target.Velocity(1));
end

zoneInfo = classifyFixedWingZone(pos, config);
inwardNormal = inwardNormalForSide(zoneInfo.BorderSide);

if isfield(zoneCfg, 'recoveryInwardDistanceRange')
    inwardRange = zoneCfg.recoveryInwardDistanceRange;
else
    inwardRange = config.fixedWing.boundary.recoveryInwardDistanceRange;
end
inwardDistance = inwardRange(1) + rand() * (inwardRange(2) - inwardRange(1));
inwardDistance = max(inwardDistance, zoneInfo.DistanceToBoundary + zones.SafeMargin * 0.5);

center = [(safe(1) + safe(2)) / 2; (safe(3) + safe(4)) / 2];
toCenter = center - pos(1:2);
if norm(toCenter) > 1e-6
    toCenter = toCenter / norm(toCenter);
else
    toCenter = inwardNormal;
end

blendDir = 0.55 * inwardNormal + 0.45 * toCenter;
if norm(blendDir) < 1e-6
    blendDir = inwardNormal;
else
    blendDir = blendDir / norm(blendDir);
end

xy = pos(1:2) + blendDir * inwardDistance;
xy(1) = min(max(xy(1), safe(1) + 50), safe(2) - 50);
xy(2) = min(max(xy(2), safe(3) + 50), safe(4) - 50);

if zoneInfo.InCriticalZone || zoneInfo.OutsideBoundary
    xy = pos(1:2) + inwardNormal * inwardDistance;
    xy(1) = min(max(xy(1), safe(1)), safe(2));
    xy(2) = min(max(xy(2), safe(3)), safe(4));
end

altitude = target.Payload.FlightLevel;
if isnan(altitude) || isempty(altitude)
    altitude = target.Position(3);
end
recoveryTarget = [xy; altitude];

if nargin >= 3 && strlength(reason) > 0
    recoveryTarget = recoveryTarget; %#ok<NASGU>
end
end

function normal = inwardNormalForSide(side)
switch string(side)
    case "left"
        normal = [1; 0];
    case "right"
        normal = [-1; 0];
    case "bottom"
        normal = [0; 1];
    otherwise
        normal = [0; -1];
end
end
