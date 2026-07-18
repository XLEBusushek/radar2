function target = createQuadcopterTarget(id, config)
% createQuadcopterTarget - Создать цель-квадрокоптер на земле.
arguments
    id (1, 1) {mustBePositive, mustBeInteger}
    config (1, 1) struct
end

worldSize = config.world.size;
qc = config.quadcopter;

position = [rand() * worldSize(1); rand() * worldSize(2); 0];
velocity = zeros(3, 1);
acceleration = zeros(3, 1);

target.ID = id;
target.Class = "air";
target.Subtype = "quadcopter";
target.Position = position;
target.Velocity = velocity;
target.Acceleration = acceleration;
target.RCS = assignRCS("quadcopter", config);
target.Visible = qc.initialVisible;
target.State = qc.initialState;
target.Mission = qc.initialMission;
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
target.History.WaypointIndex = 1;
target.History.DistanceToWaypoint = nan;
target.History.MissionComplete = false;
target.History.PreviousDistanceToWaypoint = nan;
target.History.NoProgressTime = 0;
target.History.ForceDirectToWaypoint = false;
target.History.TotalXYExcursion = 0;
target.History.MaxAltitudeReached = position(3);
target.History.MinAltitudeReached = position(3);
target.History.LastNavigationEvent = "initial";

mission = generateQuadcopterMission(position, config);

target.Payload.HomePosition = mission.HomePosition;
target.Payload.Waypoints = mission.Waypoints;
target.Payload.CurrentWaypointIndex = mission.CurrentWaypointIndex;
target.Payload.CurrentWaypoint = mission.CurrentWaypoint;
target.Payload.WaypointArrivalRadius = mission.WaypointArrivalRadius;

target.Payload.TakeoffTargetAltitude = [];
target.Payload.HoverDuration = [];
target.Payload.ScanDuration = [];
target.Payload.ScanCenter = [];
target.Payload.ScanRadius = 0;
target.Payload.ScanStartTime = [];
target.Payload.ScanAngle = 0;
target.Payload.ScanDirection = 1;
target.Payload.HoverAnchor = [];

target.Payload.DesiredSpeed = 0;
target.Payload.DesiredVelocity = zeros(3, 1);
target.Payload.DesiredAltitude = position(3);
target.Payload.DistanceToWaypoint = [];
target.Payload.MissionComplete = false;
target.Payload.PreviousDistanceToWaypoint = [];
target.Payload.NoProgressTime = 0;
target.Payload.ForceDirectToWaypoint = false;
target.Payload.ConsecutiveHoverCount = 0;
target.Payload.ConsecutiveScanCount = 0;
target.Payload.TotalXYExcursion = 0;
target.Payload.LastPositionForExcursion = position;
target.Payload.MaxAltitudeReached = position(3);
target.Payload.MinAltitudeReached = position(3);
target.Payload.LastNavigationEvent = "initial";
target.Payload.NavigationFallbackCount = mission.NavigationFallbackCount;

target.Payload.TransitionCount = 0;
target.Payload.LastState = "";
target.Payload.NextState = "";
target.Payload.LastTransitionReason = "initial";
target.Payload.StateEntryTime = 0;

target = initializeBehaviorProfile(target, config);
target.History.BehaviorAction = string(target.Behavior.LastDecision);
target.History.BehaviorReason = "";
target.History.BehaviorGoal = string(target.Behavior.CurrentGoal);
target.History.BehaviorProfile = string(target.Behavior.Profile);

target.Metadata.CreatedBy = "createQuadcopterTarget";
target.Metadata.CreatedAtSimTime = 0;
target.Metadata.Version = "0.7.0";

validateTarget(target, config);
end
