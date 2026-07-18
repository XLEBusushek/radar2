function target = updateBehaviorMemory(target, action, reason, context, config)
% updateBehaviorMemory - Обновить память поведения после решения.
arguments
    target (1, 1) struct
    action (1, 1) string
    reason (1, 1) string
    context (1, 1) struct
    config (1, 1) struct
end

action = string(action);
memory = target.Behavior.Memory;

memory.LastAction = action;
memory.LastActionTime = context.Time;

fieldName = matlab.lang.makeValidName(char(action));
if isfield(memory.ActionCounts, fieldName)
    memory.ActionCounts.(fieldName) = memory.ActionCounts.(fieldName) + 1;
else
    memory.ActionCounts.(fieldName) = 1;
end

memory.RecentActions = [memory.RecentActions; action];
maxLen = 10;
if isfield(config, 'behavior') && isfield(config.behavior, 'recentActionMemoryLength')
    maxLen = config.behavior.recentActionMemoryLength;
end
if numel(memory.RecentActions) > maxLen
    memory.RecentActions = memory.RecentActions(end - maxLen + 1:end);
end

cooldownDuration = 5.0;
if isfield(config, 'behavior') && isfield(config.behavior, 'cooldownDefault')
    cooldownDuration = config.behavior.cooldownDefault;
end
memory.Cooldowns.(fieldName) = context.Time + cooldownDuration;

progressMetric = context.DistanceToTarget;
if ~isnan(progressMetric) && ~isnan(memory.LastProgressMetric)
    if abs(progressMetric - memory.LastProgressMetric) < 1
        memory.NoProgressTime = memory.NoProgressTime + target.Behavior.DecisionPeriod;
    else
        memory.NoProgressTime = 0;
    end
end
memory.LastProgressMetric = progressMetric;

target.Behavior.Memory = memory;
target.Behavior.LastDecision = action;
target.Behavior.LastDecisionTime = context.Time;
target.Behavior.NextDecisionTime = context.Time + target.Behavior.DecisionPeriod;
end
