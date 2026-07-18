function bird = maybeRetargetBird(bird, scenario, config)
% maybeRetargetBird - Сменить цель в крейсере или выполнить пролёт мимо целевого дерева.
arguments
    bird (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
end

if string(bird.State) ~= "Cruise"
    return;
end

if isempty(bird.Payload.TargetTreeID)
    return;
end

realism = config.birds.realism;
trees = scenario.Trees;
oldTargetID = bird.Payload.TargetTreeID;
currentTreeID = bird.Payload.CurrentTreeID;

targetPos = bird.Payload.TargetTreePosition(:);
distXY = norm(bird.Position(1:2) - targetPos(1:2));
approachRadius = config.birds.landing.approachRadius;

if distXY < approachRadius && rand() < realism.flyByProbability
    flyByCount = 0;
    if isfield(bird.Payload, 'SequentialFlyByCount')
        flyByCount = bird.Payload.SequentialFlyByCount;
    end
    if flyByCount >= realism.maxSequentialFlyBy
        return;
    end

    newTargetID = selectAlternateTree(bird, trees, config, oldTargetID, currentTreeID);
    if isempty(newTargetID)
        return;
    end

    bird.Payload.TargetTreeID = newTargetID;
    bird = reinitializeBirdCruiseTarget(bird, scenario, config);
    bird.Payload.FlyByCount = bird.Payload.FlyByCount + 1;
    bird.Payload.SequentialFlyByCount = flyByCount + 1;
    bird.Payload.LastRealismEvent = "flyBy";
    bird.Payload.BlockLandingThisStep = true;
    return;
end

if rand() >= realism.retargetProbability
    return;
end

newTargetID = selectAlternateTree(bird, trees, config, oldTargetID, currentTreeID);
if isempty(newTargetID)
    return;
end

bird.Payload.TargetTreeID = newTargetID;
bird = reinitializeBirdCruiseTarget(bird, scenario, config);
bird.Payload.RetargetCount = bird.Payload.RetargetCount + 1;
bird.Payload.LastRealismEvent = "retarget";
end

function targetTreeID = selectAlternateTree(bird, trees, config, oldTargetID, currentTreeID)
targetTreeID = selectRealisticTargetTree(bird, trees, config);
if targetTreeID == oldTargetID || targetTreeID == currentTreeID
    treeIDs = [trees.ID];
    candidates = treeIDs(treeIDs ~= currentTreeID & treeIDs ~= oldTargetID);
    if isempty(candidates)
        targetTreeID = [];
        return;
    end
    targetTreeID = candidates(randi(numel(candidates)));
end
end
