function bird = reinitializeBirdCruiseTarget(bird, scenario, config)
% reinitializeBirdCruiseTarget - Обновить цель крейсерского полёта после смены цели или пролёта.
arguments
    bird (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
end

trees = scenario.Trees;
treeIdx = find([trees.ID] == bird.Payload.TargetTreeID, 1);
if isempty(treeIdx)
    return;
end

bird.Payload.TargetTreePosition = trees(treeIdx).TopPosition(:);
bird.Payload.ArrivedToTargetTree = false;
bird.Payload.CircleBeforeLanding = false;
bird.Payload.CircleCenter = [];
bird.Payload.CircleRadius = 0;
bird.Payload.CircleEndTime = [];
bird.Payload.CircleWaypoint = [];

bird.Payload.CruiseStartPosition = bird.Position(:);
targetPoint = getBirdTargetPoint(bird);
bird.Payload.CruiseTargetPosition = targetPoint(:);

if isfield(config.birds, 'curvedCruise') && config.birds.curvedCruise.enabled
    bird = initializeCruiseCurve(bird, config);
else
    bird.Payload.CurveWaypoint = bird.Payload.CruiseTargetPosition(:);
end
end
