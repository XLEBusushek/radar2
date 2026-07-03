function target = fw2_createFixedWingTarget(id, config)
% fw2_createFixedWingTarget - Create fixed-wing2 UAV target.
arguments
    id (1, 1) {mustBePositive, mustBeInteger}
    config (1, 1) struct
end

fw2 = config.fixedWing2;
zones = fw2_getZoneBounds(config);
safe = zones.SafeZone;

xy = [safe(1) + rand() * (safe(2) - safe(1)); safe(3) + rand() * (safe(4) - safe(3))];
ap = fw2.altitudeProfile;
levels = ap.levelRange(1):ap.levelSpacing:ap.levelRange(2);
flightLevel = levels(randi(numel(levels)));
position = [xy; flightLevel];
heading = 2 * pi * rand();
velocity = [cos(heading); sin(heading); 0];

mission = fw2_generateMission(position, heading, config);

target.ID = id;
target.Class = "air";
target.Subtype = "fixedWingUAV";
target.Position = position;
target.Velocity = velocity;
target.Acceleration = zeros(3, 1);
target.RCS = assignRCS("fixedWingUAV", config);
target.Visible = fw2.initialVisible;
target.State = fw2.initialState;
target.Mission = fw2.initialMission;
target.TimeInState = 0;
target.CurrentTime = 0;
target.StateMatrix = computeStateMatrix(target.Position, target.Velocity);
target.Metadata.CreatedBy = "fw2_createFixedWingTarget";
target.Metadata.CreatedAtSimTime = 0;
target.Metadata.Version = "2.0.0";
target.Metadata.FW2 = true;

target.Payload.RoutePoints = mission.RoutePoints;
target.Payload.RouteIndex = 1;
target.Payload.RouteComplete = false;
target.Payload.HomePoint = position;
target.Payload.RecoveryPoint = [];
target.Payload.MissionID = mission.MissionID;

target.Payload.CurrentLegStart = position;
target.Payload.CurrentLegEnd = mission.RoutePoints(1, :).';
target.Payload.CurrentLegVector = [cos(heading); sin(heading); 0];
target.Payload.CurrentLegLength = norm(target.Payload.CurrentLegEnd(1:2) - position(1:2));
target.Payload.CurrentLegProgress = 0;

target.Payload.CurrentHeading = heading;
target.Payload.TargetHeading = heading;
target.Payload.HeadingErrorDeg = 0;
target.Payload.TurnRateCommandDeg = 0;

target = fw2_initializeSpeedProfile(target, config);
target = fw2_initializeAltitudeProfile(target, config);

target.Payload.SafeZone = zones.SafeZone;
target.Payload.DistanceToBoundary = min([position(1), config.world.size(1) - position(1), ...
    position(2), config.world.size(2) - position(2)]);
target.Payload.InSafeZone = true;
target.Payload.InWarningZone = false;
target.Payload.InCriticalZone = false;
target.Payload.BorderFollowing = false;
target.Payload.BorderFollowingTime = 0;

target.Payload.LoiterUsed = false;
target.Payload.LoiterCenter = nan(3, 1);
target.Payload.LoiterRadius = nan;
target.Payload.LoiterStartTime = nan;
target.Payload.LoiterDuration = nan;
target.Payload.LoiterDirection = 1;
target.Payload.LoiterAngle = 0;

target.Payload.LastFW2Event = "initial";
target.Payload.InSafeZone = true;

target = fw2_initializeRoute(target, config);

localConfig = config;
localConfig.behavior.enabled = false;
target = initializeBehaviorProfile(target, localConfig);

target.History = fw2_createInitialHistory(target);
validateTarget(target, config);
end

function history = fw2_createInitialHistory(target)
history.Time = 0;
history.Position = target.Position.';
history.Velocity = target.Velocity.';
history.Acceleration = target.Acceleration.';
history.State = string(target.State);
history.Visible = target.Visible;
history.RCS = target.RCS;
history.RouteIndex = target.Payload.RouteIndex;
history.CurrentLegProgress = target.Payload.CurrentLegProgress;
history.CurrentHeading = target.Payload.CurrentHeading;
history.TargetHeading = target.Payload.TargetHeading;
history.HeadingErrorDeg = 0;
history.TurnRateCommandDeg = 0;
history.BaseCruiseSpeed = target.Payload.BaseCruiseSpeed;
history.CurrentSpeed = target.Payload.CurrentSpeed;
history.TargetSpeed = target.Payload.TargetSpeed;
history.SpeedProfileEvent = "";
history.CurrentFlightLevel = target.Payload.CurrentFlightLevel;
history.FlightLevel = target.Payload.FlightLevel;
history.TargetFlightLevel = target.Payload.TargetFlightLevel;
history.AltitudeError = 0;
history.DesiredClimbRate = 0;
history.ClimbAngleDeg = 0;
history.AltitudeProfileEvent = "";
history.DistanceToBoundary = target.Payload.DistanceToBoundary;
history.InWarningZone = false;
history.InCriticalZone = false;
history.BorderFollowing = false;
history.LastFW2Event = "initial";
history.BehaviorAction = "";
history.BehaviorReason = "";
history.BehaviorGoal = "";
history.BehaviorProfile = "";
end
