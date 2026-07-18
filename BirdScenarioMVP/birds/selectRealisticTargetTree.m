function targetTreeID = selectRealisticTargetTree(bird, trees, config)
% selectRealisticTargetTree - Выбрать целевое дерево с учётом реалистичности.
arguments
    bird (1, 1) struct
    trees struct
    config (1, 1) struct
end

if numel(trees) < 2
    error('selectRealisticTargetTree:InsufficientTrees', ...
        'At least 2 trees are required to select a target tree.');
end

currentTreeID = bird.Payload.CurrentTreeID;
treeIDs = [trees.ID];
candidates = treeIDs(treeIDs ~= currentTreeID);

if isempty(candidates)
    targetTreeID = selectTargetTree(bird, trees);
    return;
end

useRealism = isfield(config.birds, 'realism') && config.birds.realism.enabled;
if ~useRealism
    targetTreeID = selectTargetTree(bird, trees);
    return;
end

realism = config.birds.realism;
oldTargetID = [];
if isfield(bird.Payload, 'TargetTreeID') && ~isempty(bird.Payload.TargetTreeID)
    oldTargetID = bird.Payload.TargetTreeID;
end

if ~isempty(oldTargetID) && rand() < realism.sameTreeAvoidanceProbability
    candidates = candidates(candidates ~= oldTargetID);
    if isempty(candidates)
        candidates = treeIDs(treeIDs ~= currentTreeID);
    end
end

minDistance = realism.minTargetTreeDistance;
maxAttempts = realism.maxTargetSelectionAttempts;
[poolIDs, treeDistances] = filterTreesByMinDistance(bird, trees, candidates, minDistance);

for attempt = 1:maxAttempts
    candidatePool = poolIDs;

    if rand() < realism.nearTreePreferenceProbability
        birdPos = bird.Position(:);
        nearIDs = [];
        for i = 1:numel(trees)
            if ~ismember(trees(i).ID, candidatePool)
                continue;
            end
            dist = norm(birdPos(1:2) - trees(i).Position(1:2));
            if dist <= realism.nearTreeRadius
                nearIDs(end + 1) = trees(i).ID; %#ok<AGROW>
            end
        end
        if ~isempty(nearIDs)
            candidatePool = nearIDs;
        end
    end

    targetTreeID = candidatePool(randi(numel(candidatePool)));
    if targetTreeID ~= currentTreeID && (isempty(oldTargetID) || targetTreeID ~= oldTargetID)
        return;
    end
end

distances = zeros(numel(poolIDs), 1);
for i = 1:numel(poolIDs)
    distances(i) = treeDistances(poolIDs(i));
end
[~, bestIdx] = max(distances);
targetTreeID = poolIDs(bestIdx);
end
