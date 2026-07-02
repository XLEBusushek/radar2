% testFixedWingMissionCompletion - Acceptance checks for mission completion (ТЗ-09C/09D).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

strategies = {"NewRoute", "ReturnHome", "LoiterEnd", "Exit"};
seeds = [42, 55, 68, 91];

for s = 1:numel(strategies)
    strategy = strategies{s};
    config = defaultConfig();
    config.sim.random.mode = "deterministic";
    config.sim.random.seed = seeds(s);
    config.behavior.enabled = true;
    config.birds.count = 0;
    config.quadcopter.count = 0;
    config.groundVehicle.count = 0;
    config.fixedWing.count = 1;
    config.fixedWing.waypointCountRange = [3, 4];
    config.fixedWing.diveProbability = 0;
    config.fixedWing.returnProbability = 0;
    config.fixedWing.flightLevel.changeProbability = 0;
    config.fixedWing.allowExitArea = strategy == "Exit";
    config.fixedWing.finalPhase.strategyWeights.NewRoute = double(strategy == "NewRoute");
    config.fixedWing.finalPhase.strategyWeights.Exit = double(strategy == "Exit");
    config.fixedWing.finalPhase.strategyWeights.ReturnHome = double(strategy == "ReturnHome");
    config.fixedWing.finalPhase.strategyWeights.LoiterEnd = double(strategy == "LoiterEnd");
    config.fixedWing.finalPhase.routeProgressThreshold = 0.65;
    config.sim.duration = 400;
    config.sim.dt = 1;
    config.visualization.enabled = false;
    config.export.enabled = false;
    config.analysis.enabled = false;

    [scenario, output] = runSimulation(config);
    uav = getScenarioFixedWingUAVs(scenario);
    uav = uav(1);

    assert(any(uav.History.FinalPhaseStarted) || any(uav.History.LastNavigationEvent == "newRoute") || ...
        any(uav.History.LastNavigationEvent == "finalPhase:newRoute"), ...
        'Strategy %s must enter final phase or regenerate route.', strategy);

    if strategy == "NewRoute"
        assert(any(uav.History.LastNavigationEvent == "newRoute") || ...
            any(uav.History.LastNavigationEvent == "finalPhase:newRoute"), ...
            'NewRoute strategy must regenerate mission.');
    end

    if strategy == "Exit"
        startIdx = find(uav.History.FinalPhaseStarted, 1, 'first');
        assert(~isempty(startIdx), 'Exit strategy must enter final phase.');
        assert(any(uav.History.State(startIdx:end) == "Exit" | ...
            uav.History.State(startIdx:end) == "ApproachExit"), ...
            'Exit strategy must use exit states.');
    end

    worldSize = config.world.size;
    positions = uav.History.Position;
    if ~config.fixedWing.allowExitArea
        assert(all(positions(:, 1) >= -1 & positions(:, 1) <= worldSize(1) + 1), ...
            'Strategy %s must stay inside world bounds.', strategy);
        assert(all(positions(:, 2) >= -1 & positions(:, 2) <= worldSize(2) + 1), ...
            'Strategy %s must stay inside world bounds.', strategy);
    end

    assert(~isempty(output), 'Output must be collected for strategy %s.', strategy);
end

disp('testFixedWingMissionCompletion passed.');
