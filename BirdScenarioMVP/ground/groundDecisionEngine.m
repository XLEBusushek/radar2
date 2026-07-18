function action = groundDecisionEngine(target, config)
% groundDecisionEngine - Устаревшее вероятностное принятие решений для наземного транспорта.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

state = string(target.State);
fsm = config.groundVehicle.fsm;

switch state
    case "Idle"
        if rand() < fsm.idle.driveProbability
            action = "ContinueDrive";
        else
            action = "Wait";
        end
    case "Drive"
        r = rand();
        if r < adjustedProbability(target, fsm.drive.stopProbability, "Stop")
            action = "Stop";
        elseif r < adjustedProbability(target, fsm.drive.stopProbability + fsm.drive.leaveRoadProbability, "LeaveRoad")
            action = "LeaveRoad";
        elseif r < fsm.drive.stopProbability + fsm.drive.leaveRoadProbability + fsm.drive.turnAroundProbability
            action = "TurnAround";
        elseif r < fsm.drive.stopProbability + fsm.drive.leaveRoadProbability + ...
                fsm.drive.turnAroundProbability + fsm.drive.changeSpeedProbability
            action = "ChangeSpeed";
        else
            action = "ContinueDrive";
        end
    case "Stop"
        if target.CurrentTime >= target.Payload.StopUntilTime && rand() < fsm.stop.driveProbability
            action = "ContinueDrive";
        else
            action = "Wait";
        end
    case "LeaveRoad"
        if rand() < fsm.leaveRoad.returnProbability
            action = "ReturnRoad";
        else
            action = "ContinueDrive";
        end
    case "ReturnRoad"
        action = "ReturnRoad";
    otherwise
        action = "Wait";
end
end

function p = adjustedProbability(target, baseProb, action)
p = baseProb;
switch action
    case "Stop"
        p = p * target.Payload.StopProbability * max(0.5, 1.5 - target.Payload.DriverAggression);
    case "LeaveRoad"
        p = p * target.Payload.LeaveRoadProbability * max(0.2, 1.6 - target.Payload.RoadDiscipline);
end
p = min(max(p, 0), 1);
end
