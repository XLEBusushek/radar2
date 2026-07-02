function target = createBirdTarget(id, config, trees)
% createBirdTarget - Create a bird target perched on a random tree.
arguments
    id (1, 1) {mustBePositive, mustBeInteger}
    config (1, 1) struct
    trees struct
end

if isempty(trees)
    error('createBirdTarget:EmptyTrees', ...
        'Cannot create bird target: trees array is empty.');
end

treeIdx = randi(numel(trees));
tree = trees(treeIdx);
position = getTreeCrownPoint(tree);
velocity = zeros(3, 1);
acceleration = zeros(3, 1);

target.ID = id;
target.Class = "bird";
target.Subtype = "bird";
target.Position = position;
target.Velocity = velocity;
target.Acceleration = acceleration;
target.RCS = assignRCS("bird", config);
target.Visible = config.birds.initialVisible;
target.State = config.birds.initialState;
target.Mission = config.birds.initialMission;
target.TimeInState = 0;
target.CurrentTime = 0;
target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);

target.History.Time = 0;
target.History.Position = target.Position.';
target.History.Velocity = target.Velocity.';
target.History.Acceleration = target.Acceleration.';
target.History.State = string(target.State);
target.History.Visible = target.Visible;
target.History.RCS = target.RCS;

perchRange = config.birds.perchTimeRange;
hiddenRange = config.birds.hiddenTimeRange;
takeoffRange = config.birds.takeoffTimeRange;

target.Payload.CurrentTreeID = tree.ID;
target.Payload.TargetTreeID = [];
target.Payload.CurrentTreePosition = tree.TopPosition;
target.Payload.TargetTreePosition = [];
target.Payload.PerchDuration = perchRange(1) + ...
    rand() * (perchRange(2) - perchRange(1));
target.Payload.HiddenDuration = hiddenRange(1) + ...
    rand() * (hiddenRange(2) - hiddenRange(1));
target.Payload.TakeoffDuration = takeoffRange(1) + ...
    rand() * (takeoffRange(2) - takeoffRange(1));
target.Payload.LastCrownPoint = target.Position;

target.Payload.StateEntryTime = 0;
target.Payload.LastState = "";
target.Payload.NextState = "";
target.Payload.TransitionCount = 0;
target.Payload.LastTransitionReason = "initial";

target.Payload.DesiredSpeed = 0;
target.Payload.DesiredVelocity = zeros(3, 1);
target.Payload.DesiredAltitude = target.Position(3);
target.Payload.TakeoffTargetAltitude = [];
target.Payload.FlightDirection = zeros(3, 1);
target.Payload.DistanceToTargetTree = [];
target.Payload.ArrivedToTargetTree = false;

target.Payload.CruiseStartPosition = [];
target.Payload.CruiseTargetPosition = [];
target.Payload.CruiseProgress = 0;
target.Payload.CruiseLateralOffset = 0;
target.Payload.CruiseVerticalOffset = 0;
target.Payload.CruiseSideDirection = zeros(3, 1);
target.Payload.LastManeuverPosition = [];
target.Payload.NextManeuverDistance = [];
target.Payload.CruisePhase = 0;
target.Payload.CurveWaypoint = [];

target.Payload.LandingTargetPoint = [];
target.Payload.LandingStartPosition = [];
target.Payload.LandingProgress = 0;
target.Payload.LandingDesiredSpeed = 0;
target.Payload.LandingComplete = false;
target.Payload.LandingDistance = [];
target.Payload.LandingStartTime = [];

target.Payload.BehaviorProfile = "normal";
target.Payload.RetargetCount = 0;
target.Payload.FlyByCount = 0;

target.Payload.IsSharpManeuverActive = false;
target.Payload.SharpManeuverEndTime = [];
target.Payload.SharpManeuverDirection = [0; 0; 0];

target.Payload.CircleBeforeLanding = false;
target.Payload.CircleCenter = [];
target.Payload.CircleRadius = 0;
target.Payload.CircleEndTime = [];
target.Payload.CircleDirection = 1;
target.Payload.LastRealismEvent = "initial";

target.Payload.ProfileLateralScale = 1.0;
target.Payload.ProfileVerticalScale = 1.0;
target.Payload.ProfileNoiseScale = 1.0;
target.Payload.ProfileCurveBlendScale = 1.0;
target.Payload.BlockLandingThisStep = false;
target.Payload.HiddenExtended = false;

target.Payload.PreviousDistanceToTargetTree = [];
target.Payload.NoProgressTime = 0;
target.Payload.ForceDirectToTarget = false;
target.Payload.BestDistanceToTargetTree = [];
target.Payload.SequentialFlyByCount = 0;

target = initializeBehaviorProfile(target, config);

target.History.TransitionReason = string(target.Payload.LastTransitionReason);
target.History.TransitionCount = target.Payload.TransitionCount;
target.History.DesiredSpeed = target.Payload.DesiredSpeed;
target.History.DesiredVelocity = target.Payload.DesiredVelocity.';
target.History.DesiredAltitude = target.Payload.DesiredAltitude;
target.History.DistanceToTargetTree = nan;
target.History.CruiseProgress = target.Payload.CruiseProgress;
target.History.CruiseLateralOffset = target.Payload.CruiseLateralOffset;
target.History.CruiseVerticalOffset = target.Payload.CruiseVerticalOffset;
target.History.CurveWaypoint = nan(1, 3);
target.History.LandingProgress = target.Payload.LandingProgress;
target.History.LandingDistance = nan;
target.History.LandingComplete = target.Payload.LandingComplete;
target.History.LandingTargetPoint = nan(1, 3);
target.History.BehaviorProfile = string(target.Payload.BehaviorProfile);
target.History.LastRealismEvent = string(target.Payload.LastRealismEvent);
target.History.RetargetCount = target.Payload.RetargetCount;
target.History.FlyByCount = target.Payload.FlyByCount;
target.History.IsSharpManeuverActive = target.Payload.IsSharpManeuverActive;
target.History.CircleBeforeLanding = target.Payload.CircleBeforeLanding;
target.History.BehaviorAction = string(target.Behavior.LastDecision);
target.History.BehaviorReason = "";
target.History.BehaviorGoal = string(target.Behavior.CurrentGoal);
target.History.BehaviorProfile = string(target.Behavior.Profile);

target.Metadata.CreatedBy = "createBirdTarget";
target.Metadata.CreatedAtSimTime = 0;
target.Metadata.Version = "0.3.0";

validateTarget(target, config);
end
