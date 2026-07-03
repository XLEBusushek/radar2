function recoveryPoint = fw2_computeSafeRecoveryPoint(target, config)
% fw2_computeSafeRecoveryPoint - One-time recovery point deep inside safe zone.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

zones = fw2_getZoneBounds(config);
safe = zones.SafeZone;
pos = target.Position(:);
worldSize = config.world.size;
inwardDist = config.fixedWing2.boundary.recoveryDistance;

[~, side] = fw2_nearestBorderSide(pos(1:2), worldSize);
inward = fw2_inwardNormal(side);
center = [(safe(1) + safe(2)) / 2; (safe(3) + safe(4)) / 2];
toCenter = center - pos(1:2);
if norm(toCenter) > 1e-6
    toCenter = toCenter / norm(toCenter);
else
    toCenter = inward;
end
blend = 0.6 * inward + 0.4 * toCenter;
blend = blend / norm(blend);
xy = pos(1:2) + blend * inwardDist;
xy(1) = min(max(xy(1), safe(1) + 50), safe(2) - 50);
xy(2) = min(max(xy(2), safe(3) + 50), safe(4) - 50);
alt = target.Payload.FlightLevel;
recoveryPoint = [xy; alt];
end

function normal = fw2_inwardNormal(side)
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

function [side, dist] = fw2_nearestBorderSide(pos, worldSize)
distances = [pos(1), worldSize(1) - pos(1), pos(2), worldSize(2) - pos(2)];
[dist, idx] = min(distances);
sides = ["left", "right", "bottom", "top"];
side = sides(idx);
end
