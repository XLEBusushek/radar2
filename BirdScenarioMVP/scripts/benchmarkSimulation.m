% benchmarkSimulation - Measure simulation and legacy-export performance.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.export.enabled = false;
config.analysis.enabled = false;
config.visualization.enabled = false;

fprintf('=== BirdScenarioMVP benchmark ===\n');
fprintf('Targets: birds=%d quads=%d fw=%d ground=%d\n', ...
    config.birds.count, config.quadcopter.count, config.fixedWing2.count, ...
    config.groundVehicle.count);
fprintf('Duration: %.0f s, dt=%.2f (%d steps)\n\n', ...
    config.sim.duration, config.sim.dt, ...
    numel(0:config.sim.dt:config.sim.duration));

modes = {
    struct('name', "legacyPerFrame=true", 'legacyPerFrame', true)
    struct('name', "legacyPerFrame=false (default)", 'legacyPerFrame', false)
};

for i = 1:numel(modes)
    runConfig = config;
    runConfig.log.legacyPerFrame = modes{i}.legacyPerFrame;

    tStart = tic;
    runSimulation(runConfig);
    simOnlyTime = toc(tStart);

    tStart = tic;
    [scenario, trajectoryLog, legacyOutput] = runSimulation(runConfig);
    fullTime = toc(tStart);

    trajectoryLog = attachTargetHistoryCache(trajectoryLog);
    tStart = tic;
    runAnalysis(trajectoryLog, runConfig);
    analysisTime = toc(tStart);

    tStart = tic;
    rebuilt = trajectoryLogToLegacyOutput(trajectoryLog, runConfig);
    rebuildTime = toc(tStart);

    tStart = tic;
    exportFromLog(trajectoryLog, runConfig, buildEnvironmentContext(scenario, runConfig), legacyOutput);
    exportTime = toc(tStart);

    fprintf('%s\n', modes{i}.name);
    fprintf('  simulation only:              %.3f s\n', simOnlyTime);
    fprintf('  simulation + legacy return:   %.3f s\n', fullTime);
    fprintf('  analysis (cached histories):  %.3f s\n', analysisTime);
    fprintf('  legacy rebuild from log:      %.3f s\n', rebuildTime);
    fprintf('  export (reuse legacy):        %.3f s\n', exportTime);
    fprintf('  frames=%d\n\n', getLogFrameCount(trajectoryLog));

    if modes{i}.legacyPerFrame
        assert(isequaln(rebuilt, legacyOutput), 'Stored legacy must match rebuild.');
    end
end

fprintf('Benchmark complete.\n');
