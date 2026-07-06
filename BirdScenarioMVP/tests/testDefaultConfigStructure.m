% testDefaultConfigStructure - Verify modular defaultConfig sections.
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();

sections = {'project', 'world', 'sim', 'birds', 'roads', 'groundVehicle', ...
    'quadcopter', 'fixedWing', 'fixedWing2', 'export', 'analysis', 'behavior', 'log'};
for i = 1:numel(sections)
    assert(isfield(config, sections{i}), 'Missing config section: %s.', sections{i});
end

assert(config.fixedWing2.enabled == true, 'fixedWing2 must be enabled by default.');
assert(config.fixedWing.count == 0, 'Legacy fixedWing count must be 0.');
assert(config.world.size(1) == 2000, 'World size mismatch.');
assert(config.birds.count == 10, 'Bird count mismatch.');
assert(config.fixedWing2.speedProfile.enabled == true, 'Speed profile must be enabled.');
assert(config.log.legacyPerFrame == false, 'legacyPerFrame must be false by default.');

config2 = defaultConfig();
assert(isequaln(config, config2), 'defaultConfig must be deterministic.');

disp('testDefaultConfigStructure passed.');
