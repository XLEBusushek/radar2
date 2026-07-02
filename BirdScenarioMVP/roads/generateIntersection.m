function [roads, intersections] = generateIntersection(roads, config)
% generateIntersection - Detect pairwise road segment crossings.
arguments
    roads (1, :) struct
    config (1, 1) struct
end

intersections = struct('ID', {}, 'Position', {}, 'RoadIDs', {}, 'SegmentIndices', {});
tol = 5;
if isfield(config, 'roads') && isfield(config.roads, 'intersectionTolerance')
    tol = config.roads.intersectionTolerance;
end

intersectionId = 0;
for i = 1:numel(roads)
    for j = (i + 1):numel(roads)
        ptsA = roads(i).Points;
        ptsB = roads(j).Points;
        for a = 1:(size(ptsA, 1) - 1)
            for b = 1:(size(ptsB, 1) - 1)
                [doesIntersect, xy] = segmentIntersection(ptsA(a, 1:2), ptsA(a + 1, 1:2), ...
                    ptsB(b, 1:2), ptsB(b + 1, 1:2), tol);
                if ~doesIntersect
                    continue;
                end
                if isDuplicateIntersection(intersections, xy, tol)
                    continue;
                end
                intersectionId = intersectionId + 1;
                intersections(intersectionId).ID = intersectionId; %#ok<AGROW>
                intersections(intersectionId).Position = [xy(:); 0]; %#ok<AGROW>
                intersections(intersectionId).RoadIDs = [roads(i).ID, roads(j).ID]; %#ok<AGROW>
                intersections(intersectionId).SegmentIndices = [a, b]; %#ok<AGROW>
                roads(i).Intersections(end + 1) = intersectionId;
                roads(j).Intersections(end + 1) = intersectionId;
            end
        end
    end
end
end

function [hit, xy] = segmentIntersection(p1, p2, q1, q2, tol)
r = p2 - p1;
s = q2 - q1;
den = cross2d(r, s);
xy = [nan; nan];
hit = false;

if abs(den) < 1e-9
    return;
end

t = cross2d(q1 - p1, s) / den;
u = cross2d(q1 - p1, r) / den;
epsTol = tol / max([norm(r), norm(s), 1]);
if t >= -epsTol && t <= 1 + epsTol && u >= -epsTol && u <= 1 + epsTol
    xy = (p1 + t * r).';
    hit = true;
end
end

function c = cross2d(a, b)
c = a(1) * b(2) - a(2) * b(1);
end

function duplicate = isDuplicateIntersection(intersections, xy, tol)
duplicate = false;
for k = 1:numel(intersections)
    if norm(intersections(k).Position(1:2) - xy(:)) <= tol
        duplicate = true;
        return;
    end
end
end
