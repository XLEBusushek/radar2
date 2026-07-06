% testDefaultConfigStructure - Verify modular defaultConfig sections.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();

sections = {'project', 'world', 'sim', 'birds', 'roads', 'groundVehicle', ...
    'quadcopter', 'fixedWing', 'fixedWing2', 'export', 'analysis', 'behavior', 'log', 'tests'};
for i = 1:numel(sections)
    assert(isfield(config, sections{i}), 'Missing config section: %s.', sections{i});
end

assert(config.fixedWing2.enabled == true, 'fixedWing2 must be enabled by default.');
assert(config.fixedWing.count == 0, 'Legacy fixedWing count must be 0.');
assert(config.world.size(1) == 2000, 'World size mismatch.');
assert(config.birds.count == 10, 'Bird count mismatch.');
assert(config.fixedWing2.speedProfile.enabled == true, 'Speed profile must be enabled.');
assert(config.log.legacyPerFrame == false, 'legacyPerFrame must be false by default.');
assert(config.log.preallocateFrames == true, 'preallocateFrames must be true by default.');
assert(config.log.historyMode == "full", 'historyMode must be full by default.');
assert(config.log.buildLegacyOutput == true, 'buildLegacyOutput must be true by default.');
assert(config.log.incrementalCsv == false, 'incrementalCsv must be false by default.');
assert(config.tests.runOnStartup == false, 'runOnStartup must be false by default.');
assert(config.export.csvFromLog == true, 'csvFromLog must be true by default.');
assert(config.export.matIncludesLegacy == false, 'matIncludesLegacy must be false by default.');

config2 = defaultConfig();
assert(isequaln(config, config2), 'defaultConfig must be deterministic.');

disp('testDefaultConfigStructure passed.');
