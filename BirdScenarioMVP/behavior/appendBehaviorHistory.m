function target = appendBehaviorHistory(target, context, weights, action, reason)
% appendBehaviorHistory - Добавить решение поведения в DecisionHistory.
arguments
    target (1, 1) struct
    context (1, 1) struct
    weights (1, 1) struct
    action (1, 1) string
    reason (1, 1) string
end

entry.Time = context.Time;
entry.Action = string(action);
entry.Reason = string(reason);
entry.State = string(context.State);
entry.Goal = string(context.CurrentGoal);
entry.ActionNames = string(weights.ActionNames(:).');
entry.Weights = weights.Values(:).';
entry.ContextSummary = summarizeContext(context);

target.Behavior.DecisionHistory(end + 1) = entry;
target.Behavior.LastWeights = weights;
target.Behavior.LastContext = context;
end

function summary = summarizeContext(context)
summary = struct( ...
    'Speed', context.Speed, ...
    'Altitude', context.Altitude, ...
    'TimeInState', context.TimeInState, ...
    'DistanceToTarget', context.DistanceToTarget, ...
    'DistanceToHome', context.DistanceToHome, ...
    'IsNearTarget', context.IsNearTarget);
end
