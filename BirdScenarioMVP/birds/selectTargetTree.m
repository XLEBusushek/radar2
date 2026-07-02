function targetTreeID = selectTargetTree(bird, trees)
% selectTargetTree - Select a random tree different from the current one.
arguments
    bird (1, 1) struct
    trees struct
end

if numel(trees) < 2
    error('selectTargetTree:InsufficientTrees', ...
        'At least 2 trees are required to select a target tree.');
end

currentTreeID = bird.Payload.CurrentTreeID;
treeIDs = [trees.ID];
candidates = treeIDs(treeIDs ~= currentTreeID);

if isempty(candidates)
    error('selectTargetTree:NoCandidates', ...
        'No alternate target tree is available for bird %d.', bird.ID);
end

targetTreeID = candidates(randi(numel(candidates)));
end
