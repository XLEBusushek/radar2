function [action, reason] = selectBehaviorAction(weights, config, target)
% selectBehaviorAction - Взвешенный случайный выбор действия поведения.
arguments
    weights (1, 1) struct
    config (1, 1) struct
    target (1, 1) struct = struct()
end

if isempty(weights.ActionNames)
    [action, reason] = defaultSafeAction(target);
    return;
end

values = weights.Values(:);
total = sum(values);

if total <= 0
    [action, reason] = defaultSafeAction(target);
    return;
end

action = string(randChoiceWeighted(weights.ActionNames, values));
idx = find(weights.ActionNames == action, 1, 'first');
if isfield(weights, 'Reasons') && numel(weights.Reasons) >= idx
    reason = string(weights.Reasons(idx));
else
    reason = "weighted";
end
end

function [action, reason] = defaultSafeAction(target)
if nargin < 1 || isempty(fieldnames(target)) || ~isfield(target, 'Class')
    action = "stay";
    reason = "fallback";
    return;
end

if target.Class == "bird"
    state = string(target.State);
    if state == "Cruise" || state == "Takeoff"
        action = "continueFlight";
    else
        action = "stay";
    end
elseif target.Class == "air"
    action = "continueTransit";
    if string(target.State) == "Idle"
        action = "wait";
    end
elseif target.Class == "ground"
    if string(target.State) == "Idle" || string(target.State) == "Stop"
        action = "Wait";
    elseif string(target.State) == "LeaveRoad" || string(target.State) == "ReturnRoad"
        action = "ReturnRoad";
    else
        action = "ContinueDrive";
    end
else
    action = "stay";
end
reason = "safeDefault";
end
