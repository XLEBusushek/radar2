% testTrees - Проверяет генерацию и визуализацию деревьев (ТЗ-02).
projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(projectRoot));

config = defaultConfig();
config.sim.random.mode = "deterministic";
config.sim.random.seed = 42;
config.behavior.enabled = false;
config.birds.realism.enabled = false;
config.quadcopter.count = 0;
setScenarioRNG(config.sim.random.seed);

trees = generateTrees(config);
assert(numel(trees) == config.environment.numTrees, ...
  'Tree count must match config.environment.numTrees.');

worldSize = config.world.size;
heightRange = config.environment.treeHeightRange;
crownRadiusRange = config.environment.crownRadiusRange;
treeMargin = config.environment.treeMargin;

for i = 1:numel(trees)
  tree = trees(i);

  assert(isfield(tree, 'ID'), 'Tree must have ID.');
  assert(isfield(tree, 'Position'), 'Tree must have Position.');
  assert(isfield(tree, 'BasePosition'), 'Tree must have BasePosition.');
  assert(isfield(tree, 'TopPosition'), 'Tree must have TopPosition.');
  assert(isfield(tree, 'Height'), 'Tree must have Height.');
  assert(isfield(tree, 'CrownRadius'), 'Tree must have CrownRadius.');

  assert(isequal(size(tree.Position), [3, 1]), 'Position must be 3x1.');
  assert(isequal(size(tree.BasePosition), [3, 1]), 'BasePosition must be 3x1.');
  assert(isequal(size(tree.TopPosition), [3, 1]), 'TopPosition must be 3x1.');

  assert(tree.Position(3) == 0, 'Position Z must be 0.');
  assert(tree.BasePosition(3) == 0, 'BasePosition Z must be 0.');
  assert(tree.TopPosition(3) == tree.Height, 'TopPosition Z must equal Height.');

  assert(tree.Height >= heightRange(1) && tree.Height <= heightRange(2), ...
    'Height must be within treeHeightRange.');
  assert(tree.CrownRadius >= crownRadiusRange(1) && ...
    tree.CrownRadius <= crownRadiusRange(2), ...
    'CrownRadius must be within crownRadiusRange.');

  assert(tree.Position(1) >= treeMargin && ...
    tree.Position(1) <= worldSize(1) - treeMargin, ...
    'Tree X must be inside world with margin.');
  assert(tree.Position(2) >= treeMargin && ...
    tree.Position(2) <= worldSize(2) - treeMargin, ...
    'Tree Y must be inside world with margin.');

  point = getTreeCrownPoint(tree);
  assert(isequal(size(point), [3, 1]), 'Crown point must be 3x1.');
  assert(all(~isnan(point)), 'Crown point must not contain NaN.');

  assert(point(1) >= 0 && point(1) <= worldSize(1), ...
    'Crown point X must be inside world.');
  assert(point(2) >= 0 && point(2) <= worldSize(2), ...
    'Crown point Y must be inside world.');
  assert(point(3) >= 0 && point(3) <= worldSize(3), ...
    'Crown point Z must be inside world.');
  assert(point(3) >= 0, 'Crown point height must not be below 0.');

  distXY = norm(point(1:2) - tree.Position(1:2));
  assert(distXY <= tree.CrownRadius * 1.5, ...
    'Crown point must be near the tree horizontally.');
end

scenario = initializeScenario(config);
plotScenario(scenario, config);

disp('testTrees passed.');
