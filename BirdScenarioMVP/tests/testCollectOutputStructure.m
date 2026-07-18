% testCollectOutputStructure - Проверка полноты полей collectOutput после рефакторинга.
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

scenario = initializeScenario(config);
outputStep = collectOutput(scenario, scenario.Time);

assert(isfield(outputStep, 'Targets'), 'Missing Targets.');
assert(isfield(outputStep, 'Birds'), 'Missing Birds.');
assert(~isempty(outputStep.Targets), 'Targets must not be empty.');

requiredFields = {'ID', 'Class', 'Subtype', 'Position', 'Velocity', 'State', ...
    'WaypointIndex', 'MissionComplete', 'CurrentSpeed', 'TargetSpeed'};
for i = 1:numel(outputStep.Targets)
  for f = 1:numel(requiredFields)
    assert(isfield(outputStep.Targets(i), requiredFields{f}), ...
        'Missing field %s on target %d.', requiredFields{f}, i);
  end
end

fw2Idx = find(arrayfun(@(t) t.Class == "air" && t.Subtype == "fixedWingUAV", scenario.Targets), 1);
if ~isempty(fw2Idx) && isfield(scenario.Targets(fw2Idx), 'Metadata') && ...
        isfield(scenario.Targets(fw2Idx).Metadata, 'FW2') && scenario.Targets(fw2Idx).Metadata.FW2
    outIdx = find([outputStep.Targets.ID] == scenario.Targets(fw2Idx).ID, 1);
    fw2Fields = {'RouteIndex', 'BaseCruiseSpeed', 'CurrentFlightLevel', 'LastFW2Event'};
    for f = 1:numel(fw2Fields)
        assert(isfield(outputStep.Targets(outIdx), fw2Fields{f}), 'Missing FW2 field %s.', fw2Fields{f});
    end
end

disp('testCollectOutputStructure passed.');
