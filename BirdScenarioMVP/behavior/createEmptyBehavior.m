function behavior = createEmptyBehavior()
% createEmptyBehavior - Создать пустую структуру Behavior с обязательными полями.
behavior.Enabled = true;
behavior.Profile = "";
behavior.Personality = createEmptyPersonality();
behavior.Memory = createEmptyBehaviorMemory();
behavior.CurrentGoal = "";
behavior.LastDecision = "";
behavior.LastDecisionTime = 0;
behavior.NextDecisionTime = 0;
behavior.DecisionPeriod = 1.0;
behavior.DecisionHistory = struct( ...
    'Time', {}, 'Action', {}, 'Reason', {}, 'State', {}, 'Goal', {}, ...
    'ActionNames', {}, 'Weights', {}, 'ContextSummary', {});
behavior.LastWeights = struct('ActionNames', strings(0, 1), 'Values', [], 'Reasons', strings(0, 1));
behavior.LastContext = struct();
end

function personality = createEmptyPersonality()
personality.Randomness = 1.0;
personality.MissionFocus = 1.0;
personality.Curiosity = 1.0;
personality.Caution = 1.0;
personality.SpeedBias = 1.0;
personality.AltitudeBias = 1.0;
personality.HoverBias = 1.0;
personality.ScanBias = 1.0;
personality.ReturnBias = 1.0;
personality.ManeuverBias = 1.0;
personality.DriverAggression = 1.0;
personality.PatrolProbability = 1.0;
personality.StopProbability = 1.0;
personality.LeaveRoadProbability = 1.0;
personality.RoadDiscipline = 1.0;
personality.Attention = 1.0;
end

function memory = createEmptyBehaviorMemory()
memory.LastAction = "";
memory.LastActionTime = 0;
memory.ActionCounts = struct();
memory.RecentActions = strings(0, 1);
memory.Cooldowns = struct();
memory.NoProgressTime = 0;
memory.LastProgressMetric = nan;
end
