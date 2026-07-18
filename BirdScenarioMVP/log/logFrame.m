function log = logFrame(scenario, log, time, config)
% logFrame - Добавить один кадр симуляции в TrajectoryLog.
arguments
    scenario (1, 1) struct
    log (1, 1) struct
    time (1, 1) double
    config (1, 1) struct
end

frame.Time = time;
frame.Targets = struct([]);

if isfield(scenario, 'Targets') && ~isempty(scenario.Targets)
    frame.Targets = logTarget(scenario.Targets(1), config);
    for i = 2:numel(scenario.Targets)
        frame.Targets(i) = logTarget(scenario.Targets(i), config);
    end
end

if shouldStoreLegacyPerFrame(config)
    frame.LegacyExport = collectOutput(scenario, time);
end

if isfield(log, 'FrameCount')
    log.FrameCount = log.FrameCount + 1;
    frameIndex = log.FrameCount;
else
    frameIndex = numel(log.Frames) + 1;
    log.FrameCount = frameIndex;
end

if isfield(log, 'PreallocatedFrameCapacity') && log.PreallocatedFrameCapacity > 0
    log.Time(frameIndex, 1) = time;
    if frameIndex == 1
        emptyFrame = struct('Time', 0, 'Targets', struct([]));
        if shouldStoreLegacyPerFrame(config)
            emptyFrame.LegacyExport = struct([]);
        end
        log.Frames = repmat(emptyFrame, log.PreallocatedFrameCapacity, 1);
    end
    log.Frames(frameIndex) = frame;
else
    if isempty(log.Frames)
        log.Frames = frame;
    else
        log.Frames(end + 1) = frame;
    end
    log.Time(end + 1, 1) = time;
end

log = appendCsvRowsFromScenario(scenario, log, time, config);
end
