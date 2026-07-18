function target = fw2_updateFixedWingTarget(target, scenario, config, dt)
% fw2_updateFixedWingTarget - Основной цикл обновления fixed-wing2.
arguments
    target (1, 1) struct
    scenario (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

target = fw2_checkBoundary(target, config, dt);
state = string(target.State);

switch state
    case "RegenerateRoute"
        target = fw2_regenerateRoute(target, config);
    case "BoundaryRecovery"
        if target.Payload.InSafeZone && ~isempty(target.Payload.RecoveryPoint)
            rp = target.Payload.RecoveryPoint(:);
            if norm(target.Position(1:2) - rp(1:2)) < 250
                target.Payload.RecoveryPoint = [];
                target.Payload.BorderFollowingTime = 0;
                target.Payload.BorderFollowing = false;
                target = fw2_regenerateRoute(target, config);
            end
        end
        target = fw2_updateNavigationCommand(target, config, dt);
    case "Return"
        hp = target.Payload.HomePoint(:);
        if norm(target.Position(1:2) - hp(1:2)) < config.fixedWing2.route.arrivalRadius
            target.State = "RegenerateRoute";
            target.Payload.LastFW2Event = "returnComplete";
            target.TimeInState = 0;
        else
            target = fw2_updateNavigationCommand(target, config, dt);
        end
    case "Loiter"
        if target.CurrentTime >= target.Payload.LoiterStartTime + target.Payload.LoiterDuration
            target.State = "Cruise";
            target.Payload.LastFW2Event = "loiterComplete";
            target.TimeInState = 0;
            target = fw2_initializeRoute(target, config);
        else
            target = fw2_updateNavigationCommand(target, config, dt);
        end
    otherwise
        target = fw2_updateMissionState(target, config);
        if string(target.State) == "Cruise" && ~target.Payload.RouteComplete
            target = fw2_maybeStartLoiter(target, config);
        end
        if string(target.State) ~= "RegenerateRoute"
            target = fw2_updateNavigationCommand(target, config, dt);
        end
end

target = fw2_updateSpeedProfile(target, config, dt);
target = fw2_updateAltitudeProfile(target, config, dt);
target = fw2_computeClimbRate(target, config);
target = fw2_limitClimbAngle(target, config);
target = fw2_updateMotion(target, config, dt);
target = fw2_applyLimits(target, config, dt);
target = fw2_clampWorldPosition(target, config);
end

function target = fw2_regenerateRoute(target, config)
heading = target.Payload.CurrentHeading;
mission = fw2_generateMission(target.Position, heading, config);
target.Payload.RoutePoints = mission.RoutePoints;
target.Payload.HomePoint = target.Position(:);
target.Payload.MissionID = mission.MissionID;
target.Payload.RouteIndex = 1;
target.Payload.RouteComplete = false;
target.Payload.LoiterUsed = false;
target.Payload.RecoveryPoint = [];
target = fw2_initializeRoute(target, config);
target.State = "Cruise";
target.Payload.LastFW2Event = "newRoute";
target.TimeInState = 0;
end

function target = fw2_maybeStartLoiter(target, config)
fw2 = config.fixedWing2;
if target.Payload.LoiterUsed
    return;
end
if target.Payload.DistanceToBoundary < fw2.loiter.minBoundaryDistance
    return;
end
if rand() >= fw2.behavior.loiterProbability
    return;
end
radius = fw2.loiter.radiusRange(1) + rand() * diff(fw2.loiter.radiusRange);
direction = 1;
if rand() < 0.5
    direction = -1;
end
heading = target.Payload.CurrentHeading;
radial = [cos(heading - direction * pi / 2); sin(heading - direction * pi / 2)];
target.Payload.LoiterCenter = target.Position(:) - radius * [radial; 0];
target.Payload.LoiterRadius = radius;
target.Payload.LoiterDirection = direction;
target.Payload.LoiterStartTime = target.CurrentTime;
target.Payload.LoiterDuration = fw2.loiter.durationRange(1) + ...
    rand() * diff(fw2.loiter.durationRange);
target.Payload.LoiterAngle = atan2(target.Position(2) - target.Payload.LoiterCenter(2), ...
    target.Position(1) - target.Payload.LoiterCenter(1));
target.Payload.LoiterUsed = true;
target.State = "Loiter";
target.Payload.LastFW2Event = "loiterStart";
target.TimeInState = 0;
end
