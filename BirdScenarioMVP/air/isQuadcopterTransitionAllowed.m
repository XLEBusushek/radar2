function allowed = isQuadcopterTransitionAllowed(currentState, nextState)
% isQuadcopterTransitionAllowed - Check FSM transition validity for quadcopters.
arguments
    currentState (1, 1) string
    nextState (1, 1) string
end

currentState = string(currentState);
nextState = string(nextState);

if currentState == nextState
    allowed = true;
    return;
end

switch currentState
    case "Idle"
        allowed = nextState == "Takeoff";
    case "Takeoff"
        allowed = nextState == "Transit";
    case "Transit"
        allowed = ismember(nextState, ["Transit", "Hover", "Scan", "Return"]);
    case "Hover"
        allowed = ismember(nextState, ["Hover", "Transit", "Scan", "Return"]);
    case "Scan"
        allowed = ismember(nextState, ["Scan", "Transit", "Return"]);
    case "Return"
        allowed = ismember(nextState, ["Return", "Landing"]);
    case "Landing"
        allowed = nextState == "Idle";
    otherwise
        allowed = false;
end
end
