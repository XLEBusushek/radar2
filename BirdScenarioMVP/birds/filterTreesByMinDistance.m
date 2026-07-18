function [poolIDs, treeDistances] = filterTreesByMinDistance(bird, trees, candidateIDs, minDistance)
% filterTreesByMinDistance - Предпочитать деревья на расстоянии не меньше minDistance от птицы.
arguments
    bird (1, 1) struct
    trees struct
    candidateIDs (1, :) double
    minDistance (1, 1) double
end

birdPos = bird.Position(:);
treeDistances = containers.Map('KeyType', 'double', 'ValueType', 'double');
farIDs = [];

for i = 1:numel(candidateIDs)
    treeID = candidateIDs(i);
    treeIdx = find([trees.ID] == treeID, 1);
    if isempty(treeIdx)
        continue;
    end
    dist = norm(birdPos(1:2) - trees(treeIdx).Position(1:2));
    treeDistances(treeID) = dist;
    if dist >= minDistance
        farIDs(end + 1) = treeID; %#ok<AGROW>
    end
end

if ~isempty(farIDs)
    poolIDs = farIDs;
else
    poolIDs = candidateIDs;
end
end
