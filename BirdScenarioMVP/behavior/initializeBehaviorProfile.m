function target = initializeBehaviorProfile(target, config)
% initializeBehaviorProfile - Назначить профиль поведения и личность цели.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

behavior = createEmptyBehavior();
behavior.Enabled = isfield(config, 'behavior') && isfield(config.behavior, 'enabled') && ...
    config.behavior.enabled;

className = string(target.Class);
subtype = string(target.Subtype);

if className == "bird"
    profiles = ["bird_normal", "bird_cautious", "bird_active"];
    behavior.Profile = profiles(randi(numel(profiles)));
    behavior.CurrentGoal = "StayPerched";
elseif className == "air" && subtype == "quadcopter"
    profiles = ["quad_recon", "quad_calm", "quad_aggressive", "quad_observer"];
    behavior.Profile = profiles(randi(numel(profiles)));
    behavior.CurrentGoal = "WaitOnGround";
elseif className == "air" && subtype == "fixedWingUAV"
    profiles = ["fixedWing_patrol", "fixedWing_cautious", "fixedWing_aggressive", "fixedWing_loiter"];
    behavior.Profile = profiles(randi(numel(profiles)));
    behavior.CurrentGoal = "ReachWaypoint";
elseif className == "ground" && subtype == "vehicle"
    profiles = ["ground_calm", "ground_aggressive", "ground_scout", "ground_patrol"];
    behavior.Profile = profiles(randi(numel(profiles)));
    behavior.CurrentGoal = "WaitOnRoad";
else
    behavior.Profile = "generic";
    behavior.CurrentGoal = "";
end

behavior.Personality = generatePersonality(behavior.Profile);
behavior.DecisionPeriod = sampleDecisionPeriod(config, className);
behavior.NextDecisionTime = behavior.DecisionPeriod;
behavior.LastDecisionTime = 0;
behavior.Memory = createEmptyBehaviorMemory();

target.Behavior = behavior;
if isfield(target, 'Payload')
    target.Payload.BehaviorProfile = behavior.Profile;
end
target = syncBehaviorGoal(target);
end

function personality = generatePersonality(profile)
personality = createEmptyPersonality();
personality.Randomness = randomCoeff();
personality.MissionFocus = randomCoeff();
personality.Curiosity = randomCoeff();
personality.Caution = randomCoeff();
personality.SpeedBias = randomCoeff();
personality.AltitudeBias = randomCoeff();
personality.HoverBias = randomCoeff();
personality.ScanBias = randomCoeff();
personality.ReturnBias = randomCoeff();
personality.ManeuverBias = randomCoeff();

switch string(profile)
    case "bird_cautious"
        personality.Caution = personality.Caution * 1.2;
        personality.Randomness = personality.Randomness * 0.85;
    case "bird_active"
        personality.Randomness = personality.Randomness * 1.2;
        personality.ManeuverBias = personality.ManeuverBias * 1.2;
    case "quad_calm"
        personality.Caution = personality.Caution * 1.15;
        personality.SpeedBias = personality.SpeedBias * 0.85;
    case "quad_aggressive"
        personality.SpeedBias = personality.SpeedBias * 1.2;
        personality.MissionFocus = personality.MissionFocus * 1.15;
    case "quad_observer"
        personality.ScanBias = personality.ScanBias * 1.25;
        personality.HoverBias = personality.HoverBias * 1.15;
    case "quad_recon"
        personality.MissionFocus = personality.MissionFocus * 1.1;
        personality.Curiosity = personality.Curiosity * 1.1;
    case "fixedWing_patrol"
        personality.MissionFocus = personality.MissionFocus * 1.2;
        personality.ReturnBias = personality.ReturnBias * 0.9;
    case "fixedWing_cautious"
        personality.Caution = personality.Caution * 1.2;
        personality.ManeuverBias = personality.ManeuverBias * 0.85;
    case "fixedWing_aggressive"
        personality.SpeedBias = personality.SpeedBias * 1.2;
        personality.ManeuverBias = personality.ManeuverBias * 1.2;
    case "fixedWing_loiter"
        personality.Curiosity = personality.Curiosity * 1.25;
        personality.MissionFocus = personality.MissionFocus * 0.9;
    case "ground_calm"
        personality.DriverAggression = personality.DriverAggression * 0.75;
        personality.SpeedBias = personality.SpeedBias * 0.85;
        personality.StopProbability = personality.StopProbability * 1.1;
        personality.RoadDiscipline = personality.RoadDiscipline * 1.2;
    case "ground_aggressive"
        personality.DriverAggression = personality.DriverAggression * 1.25;
        personality.SpeedBias = personality.SpeedBias * 1.25;
        personality.StopProbability = personality.StopProbability * 0.8;
    case "ground_scout"
        personality.LeaveRoadProbability = personality.LeaveRoadProbability * 1.25;
        personality.Curiosity = personality.Curiosity * 1.2;
        personality.RoadDiscipline = personality.RoadDiscipline * 0.8;
    case "ground_patrol"
        personality.PatrolProbability = personality.PatrolProbability * 1.25;
        personality.StopProbability = personality.StopProbability * 1.15;
        personality.Attention = personality.Attention * 1.15;
end

personality = clampPersonality(personality);
end

function value = randomCoeff()
value = 0.5 + rand();
end

function personality = clampPersonality(personality)
fields = fieldnames(personality);
for i = 1:numel(fields)
    personality.(fields{i}) = min(max(personality.(fields{i}), 0.5), 1.5);
end
end

function period = sampleDecisionPeriod(config, className)
if className == "ground" && isfield(config, 'groundVehicle') && ...
        isfield(config.groundVehicle, 'decisionPeriodRange')
    r = config.groundVehicle.decisionPeriodRange;
    period = r(1) + rand() * (r(2) - r(1));
elseif isfield(config, 'behavior') && isfield(config.behavior, 'decisionPeriodRange')
    r = config.behavior.decisionPeriodRange;
    period = r(1) + rand() * (r(2) - r(1));
else
    period = 1.0;
end
end

function target = syncBehaviorGoal(target)
if ~isfield(target, 'Behavior')
    return;
end

state = string(target.State);
if target.Class == "bird"
    switch state
        case "Perched"
            target.Behavior.CurrentGoal = "StayPerched";
        case "Takeoff"
            target.Behavior.CurrentGoal = "TakeoffToTree";
        case "Cruise"
            target.Behavior.CurrentGoal = "FlyToTree";
        case "Landing"
            target.Behavior.CurrentGoal = "LandOnTree";
        case "Hidden"
            target.Behavior.CurrentGoal = "HideInTree";
    end
elseif target.Class == "air" && target.Subtype == "quadcopter"
    switch state
        case "Idle"
            target.Behavior.CurrentGoal = "WaitOnGround";
        case "Takeoff"
            target.Behavior.CurrentGoal = "TakeoffToAltitude";
        case "Transit"
            target.Behavior.CurrentGoal = "ReachWaypoint";
        case "Hover"
            target.Behavior.CurrentGoal = "ObserveArea";
        case "Scan"
            target.Behavior.CurrentGoal = "ScanArea";
        case "Return"
            target.Behavior.CurrentGoal = "ReturnHome";
        case "Landing"
            target.Behavior.CurrentGoal = "LandHome";
    end
elseif target.Class == "air" && target.Subtype == "fixedWingUAV"
    switch state
        case "Cruise"
            target.Behavior.CurrentGoal = "ReachWaypoint";
        case "Turn"
            target.Behavior.CurrentGoal = "AlignHeading";
        case "Climb"
            target.Behavior.CurrentGoal = "ClimbToAltitude";
        case "Descend"
            target.Behavior.CurrentGoal = "DescendToAltitude";
        case "Loiter"
            target.Behavior.CurrentGoal = "LoiterArea";
        case "Dive"
            target.Behavior.CurrentGoal = "Dive";
        case "Recover"
            target.Behavior.CurrentGoal = "RecoverAltitude";
        case "Return"
            target.Behavior.CurrentGoal = "ReturnHome";
        case "ExitArea"
            target.Behavior.CurrentGoal = "ExitArea";
    end
elseif target.Class == "ground" && target.Subtype == "vehicle"
    switch state
        case "Idle"
            target.Behavior.CurrentGoal = "WaitOnRoad";
        case "Drive"
            target.Behavior.CurrentGoal = "FollowRoad";
        case "Stop"
            target.Behavior.CurrentGoal = "HoldPosition";
        case "Turn"
            target.Behavior.CurrentGoal = "TurnAround";
        case "LeaveRoad"
            target.Behavior.CurrentGoal = "OffroadExcursion";
        case "ReturnRoad"
            target.Behavior.CurrentGoal = "ReturnToRoad";
    end
end
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
