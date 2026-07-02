function allowed = isBirdStateTransitionAllowed(currentState, nextState)
% isBirdStateTransitionAllowed - Check whether a bird state transition is valid.
currentState = string(currentState);
nextState = string(nextState);

if currentState == nextState
    allowed = true;
    return;
end

allowed = (currentState == "Perched" && nextState == "Takeoff") || ...
    (currentState == "Takeoff" && nextState == "Cruise") || ...
    (currentState == "Cruise" && nextState == "Landing") || ...
    (currentState == "Landing" && nextState == "Hidden") || ...
    (currentState == "Hidden" && nextState == "Perched");
end
