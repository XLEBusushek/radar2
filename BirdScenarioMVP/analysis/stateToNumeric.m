function value = stateToNumeric(state)
% stateToNumeric - Преобразовать имя состояния FSM цели в числовой код для графика.
arguments
    state (1, 1) string
end

switch string(state)
    case "Perched"
        value = 1;
    case "Takeoff"
        value = 2;
    case "Cruise"
        value = 3;
    case "Landing"
        value = 4;
    case "Hidden"
        value = 5;
    case "Idle"
        value = 10;
    case "Transit"
        value = 11;
    case "Hover"
        value = 12;
    case "Scan"
        value = 13;
    case "Return"
        value = 14;
    case "Drive"
        value = 20;
    case "Stop"
        value = 21;
    case "Turn"
        value = 22;
    case "LeaveRoad"
        value = 23;
    case "ReturnRoad"
        value = 24;
    case "Climb"
        value = 30;
    case "Descend"
        value = 31;
    case "Loiter"
        value = 32;
    case "Dive"
        value = 33;
    case "Recover"
        value = 34;
    case "ExitArea"
        value = 35;
    case "ApproachExit"
        value = 36;
    case "AlignExit"
        value = 37;
    case "Exit"
        value = 38;
    case "LoiterEnd"
        value = 39;
    case "ReturnHome"
        value = 40;
    otherwise
        value = NaN;
end
end
