% testTrajectoryLogStructure - Verify TrajectoryLog pipeline and legacy compat.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.behavior.enabled = false;
config.sim.duration = 5;
config.sim.dt = 1;
config.visualization.enabled = false;
config.export.enabled = false;
config.analysis.enabled = false;
setScenarioRNG(42);

[scenario, trajectoryLog, legacyOutput] = runSimulation(config);

assert(isfield(trajectoryLog, 'SimulationInfo'), 'Missing SimulationInfo.');
assert(isfield(trajectoryLog, 'Frames'), 'Missing Frames.');
assert(isfield(trajectoryLog, 'Time'), 'Missing Time.');
assert(numel(trajectoryLog.Frames) == numel(legacyOutput), 'Frame count mismatch.');

frame = trajectoryLog.Frames(1);
assert(isfield(frame, 'Time'), 'Frame missing Time.');
assert(isfield(frame, 'Targets'), 'Frame missing Targets.');
assert(~isempty(frame.Targets), 'Frame targets must not be empty.');

t = frame.Targets(1);
required = {'ID', 'Type', 'Subtype', 'Position', 'Velocity', 'Acceleration', ...
    'State', 'RCS', 'Visible', 'Heading', 'Payload'};
for f = 1:numel(required)
    assert(isfield(t, required{f}), 'Missing log field %s.', required{f});
end

legacyFromLog = trajectoryLogToLegacyOutput(trajectoryLog, config);
assert(numel(legacyFromLog) == numel(legacyOutput), 'Legacy adapter length mismatch.');
assert(legacyFromLog(1).Time == legacyOutput(1).Time, 'Legacy time mismatch.');

result = runAnalysis(trajectoryLog, config);
assert(isfield(result, 'Statistics'), 'Missing Statistics.');
assert(isfield(result, 'Metrics'), 'Missing Metrics.');
assert(isfield(result, 'Events'), 'Missing Events.');
assert(isfield(result, 'Summary'), 'Missing Summary.');
assert(result.Statistics.TargetCount > 0, 'Target count must be positive.');

disp('testTrajectoryLogStructure passed.');
