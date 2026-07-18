function target = createGroundVehicleTarget(id, config, roadNetwork)
% createGroundVehicleTarget - Создание наземной транспортной цели на дороге.
arguments
    id (1, 1) {mustBePositive, mustBeInteger}
    config (1, 1) struct
    roadNetwork (1, 1) struct
end

gv = config.groundVehicle;
mission = generateGroundMission(roadNetwork, config);
position = mission.HomePosition(:);
position(3) = 0;

target.ID = id;
target.Class = "ground";
target.Subtype = "vehicle";
target.Position = position;
target.Velocity = zeros(3, 1);
target.Acceleration = zeros(3, 1);
target.RCS = assignRCS("ground", config);
target.Visible = gv.initialVisible;
target.State = gv.initialState;
target.Mission = gv.initialMission;
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
target.History.CurrentRoad = mission.CurrentRoadID;
target.History.CurrentEdgeID = mission.CurrentEdgeID;
target.History.Waypoint = mission.CurrentWaypoint(:).';
target.History.RoadID = mission.CurrentRoadID;
target.History.SpeedLimit = mission.CurrentSpeedLimit;
target.History.RoadDeviation = 0;
target.History.RouteProgress = 0;
target.History.LookaheadPoint = mission.Route.LookaheadPoint(:).';
target.History.RouteRoadID = mission.CurrentRoadID;
target.History.OnRoad = true;
target.History.IsOffRoad = false;
target.History.DriverProfile = "initial";
target.History.GroundAction = "initial";
target.History.DesiredSpeed = 0;
target.History.Decision = "initial";
target.History.WaypointIndex = 1;
target.History.DistanceToWaypoint = norm(mission.CurrentWaypoint(:) - position);
target.History.MissionComplete = false;
target.History.PreviousDistanceToWaypoint = nan;
target.History.NoProgressTime = nan;
target.History.ForceDirectToWaypoint = false;
target.History.TotalXYExcursion = nan;
target.History.MaxAltitudeReached = nan;
target.History.MinAltitudeReached = nan;
target.History.LastNavigationEvent = "initial";

target.Payload.HomePosition = mission.HomePosition;
target.Payload.Waypoints = mission.Waypoints;
target.Payload.WaypointRoadIDs = mission.WaypointRoadIDs;
target.Payload.WaypointEdgeIDs = mission.WaypointEdgeIDs;
target.Payload.WaypointSpeedLimits = mission.WaypointSpeedLimits;
target.Payload.WaypointRouteDistances = mission.WaypointRouteDistances;
target.Payload.Route = mission.Route;
target.Payload.RoadRoute = mission.RoadRoute;
target.Payload.RoutePoints = mission.Route.Points;
target.Payload.RouteProgress = 0;
target.Payload.RouteRoadID = mission.CurrentRoadID;
target.Payload.RouteDestinationNodeID = mission.RouteDestinationNodeID;
target.Payload.LookaheadPoint = mission.Route.LookaheadPoint(:);
target.Payload.OnRoad = true;
target.Payload.IsOffRoad = false;
target.Payload.CurrentWaypointIndex = mission.CurrentWaypointIndex;
target.Payload.CurrentWaypoint = mission.CurrentWaypoint;
target.Payload.CurrentRoadID = mission.CurrentRoadID;
target.Payload.CurrentEdgeID = mission.CurrentEdgeID;
target.Payload.CurrentRoadPoint = target.Position;
target.Payload.CurrentRoadIndex = mission.CurrentRoadIndex;
target.Payload.SpeedLimit = mission.CurrentSpeedLimit;
target.Payload.WaypointArrivalRadius = gv.waypointArrivalRadius;
target.Payload.LookaheadDistance = gv.lookaheadDistance;
target.Payload.DesiredSpeed = 0;
target.Payload.DesiredVelocity = zeros(3, 1);
target.Payload.DesiredAltitude = 0;
target.Payload.DistanceToWaypoint = norm(mission.CurrentWaypoint(:) - position);
target.Payload.MissionComplete = false;
target.Payload.RoadDeviation = 0;
target.Payload.NearestRoadPoint = position;
target.Payload.PurePursuitPoint = mission.CurrentWaypoint;
target.Payload.OffroadTarget = [];
target.Payload.OffRoadTarget = [];
target.Payload.OffroadDistance = 0;
target.Payload.ReturnRoadPoint = [];
target.Payload.ReturnRouteDistance = 0;
target.Payload.StopUntilTime = 0;
target.Payload.LastDecision = "initial";
target.Payload.GroundAction = "initial";
target.Payload.LastNavigationEvent = "initial";
target.Payload.NextGroundDecisionTime = sampleDecisionTime(gv);

target.Payload.DriverAggression = 0.5 + rand();
target.Payload.DriverProfile = selectDriverProfile();
target.Payload.PatrolProbability = rand();
target.Payload.StopProbability = 0.5 + rand();
target.Payload.LeaveRoadProbability = 0.5 + rand();
target.Payload.SpeedBias = 0.5 + rand();
target.Payload.RoadDiscipline = 0.5 + rand();
target.Payload.Attention = 0.5 + rand();

target.Payload.TransitionCount = 0;
target.Payload.LastState = "";
target.Payload.NextState = "";
target.Payload.LastTransitionReason = "initial";
target.Payload.StateEntryTime = 0;

target = initializeBehaviorProfile(target, config);
target.Payload.BehaviorProfile = target.Behavior.Profile;
target.History.BehaviorAction = string(target.Behavior.LastDecision);
target.History.BehaviorReason = "";
target.History.BehaviorGoal = string(target.Behavior.CurrentGoal);
target.History.BehaviorProfile = string(target.Behavior.Profile);

target.Metadata.CreatedBy = "createGroundVehicleTarget";
target.Metadata.CreatedAtSimTime = 0;
target.Metadata.Version = "0.8.0";

validateTarget(target, config);
end

function t = sampleDecisionTime(gv)
range = gv.decisionPeriodRange;
t = range(1) + rand() * (range(2) - range(1));
end

function profile = selectDriverProfile()
profiles = ["aggressive", "cautious", "patrol", "scout"];
profile = profiles(randi(numel(profiles)));
end
