function target = fw2_updateNavigationCommand(target, config, dt)
% fw2_updateNavigationCommand - Leg-based heading commands (not waypoint attraction).
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

state = string(target.State);
fw2 = config.fixedWing2;

switch state
    case "BoundaryRecovery"
        if ~isempty(target.Payload.RecoveryPoint)
            rp = target.Payload.RecoveryPoint(:);
            target.Payload.TargetHeading = atan2(rp(2) - target.Position(2), rp(1) - target.Position(1));
        end
    case "Return"
        hp = target.Payload.HomePoint(:);
        target.Payload.TargetHeading = atan2(hp(2) - target.Position(2), hp(1) - target.Position(1));
    case "Loiter"
        target = fw2_updateLoiterHeading(target, dt);
    case "Turn"
        target = fw2_applyHeadingStep(target, config, dt);
        err = abs(fw2_computeHeadingError(target.Payload.CurrentHeading, target.Payload.TargetHeading));
        if err < 3 && target.TimeInState >= fw2.turn.minTurnTime
            target.State = "Cruise";
            target.Payload.LastFW2Event = "turnComplete";
            target.TimeInState = 0;
        end
        return;
    case "Cruise"
        if ~target.Payload.RouteComplete
            legDir = target.Payload.CurrentLegVector(:);
            target.Payload.TargetHeading = atan2(legDir(2), legDir(1));
            legEnd = target.Payload.CurrentLegEnd(:);
            distToEnd = norm(legEnd(1:2) - target.Position(1:2));
            if distToEnd < fw2.route.preTurnDistance && ...
                    target.Payload.RouteIndex < size(target.Payload.RoutePoints, 1)
                nextIdx = target.Payload.RouteIndex + 1;
                if nextIdx <= size(target.Payload.RoutePoints, 1)
                    if nextIdx == 1
                        nextStart = target.Payload.HomePoint(:);
                    else
                        nextStart = target.Payload.RoutePoints(nextIdx - 1, :).';
                    end
                    nextEnd = target.Payload.RoutePoints(nextIdx, :).';
                    nextVec = nextEnd - nextStart;
                    if norm(nextVec(1:2)) > 1e-6
                        target.Payload.TargetHeading = atan2(nextVec(2), nextVec(1));
                        target.State = "Turn";
                        target.Payload.LastFW2Event = "preTurn";
                        target.TimeInState = 0;
                    end
                end
            end
        end
    otherwise
        return;
end

target = fw2_applyHeadingStep(target, config, dt);
end

function target = fw2_applyHeadingStep(target, config, dt)
maxDelta = deg2rad(config.fixedWing2.turn.maxTurnRateDeg) * dt;
err = fw2_wrapAngle(target.Payload.TargetHeading - target.Payload.CurrentHeading);
delta = min(max(err, -maxDelta), maxDelta);
target.Payload.TurnRateCommandDeg = delta * 180 / pi / dt;
target.Payload.CurrentHeading = fw2_wrapAngle(target.Payload.CurrentHeading + delta);
target.Payload.HeadingErrorDeg = fw2_computeHeadingError(target.Payload.CurrentHeading, target.Payload.TargetHeading);
end

function target = fw2_updateLoiterHeading(target, dt)
center = target.Payload.LoiterCenter(:);
radius = target.Payload.LoiterRadius;
direction = target.Payload.LoiterDirection;
target.Payload.LoiterAngle = target.Payload.LoiterAngle + direction * (target.Payload.CurrentSpeed / radius) * dt;
target.Payload.TargetHeading = target.Payload.LoiterAngle + direction * pi / 2;
target.Payload.CurrentHeading = target.Payload.TargetHeading;
target.Payload.HeadingErrorDeg = 0;
target.Payload.TurnRateCommandDeg = 0;
end
