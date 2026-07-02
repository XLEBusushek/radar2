function stateConfig = getBirdFSMConfig(state, config)
% getBirdFSMConfig - Return FSM timing and probability settings for a state.
arguments
    state (1, 1) string
    config (1, 1) struct
end

if ~isfield(config, 'birds') || ~isfield(config.birds, 'fsm')
    error('getBirdFSMConfig:MissingConfig', 'config.birds.fsm is required.');
end

fsm = config.birds.fsm;

switch string(state)
    case "Perched"
        stateConfig.minTime = fsm.perched.minTime;
        stateConfig.maxTime = fsm.perched.maxTime;
        stateConfig.probability = fsm.perched.takeoffProbability;
        stateConfig.nextState = "Takeoff";
    case "Takeoff"
        stateConfig.minTime = fsm.takeoff.minTime;
        stateConfig.maxTime = fsm.takeoff.maxTime;
        stateConfig.probability = fsm.takeoff.cruiseProbability;
        stateConfig.nextState = "Cruise";
    case "Cruise"
        stateConfig.minTime = fsm.cruise.minTime;
        stateConfig.maxTime = fsm.cruise.maxTime;
        stateConfig.probability = fsm.cruise.landingProbability;
        stateConfig.nextState = "Landing";
    case "Landing"
        stateConfig.minTime = fsm.landing.minTime;
        stateConfig.maxTime = fsm.landing.maxTime;
        stateConfig.probability = fsm.landing.hiddenProbability;
        stateConfig.nextState = "Hidden";
    case "Hidden"
        stateConfig.minTime = fsm.hidden.minTime;
        stateConfig.maxTime = fsm.hidden.maxTime;
        stateConfig.probability = fsm.hidden.perchedProbability;
        stateConfig.nextState = "Perched";
    otherwise
        error('getBirdFSMConfig:UnknownState', ...
            'Unknown bird state: %s', string(state));
end
end
