function trees = generateTrees(config)
% generateTrees - Генерирует деревья внутри мира симуляции.
arguments
    config (1, 1) struct
end

requiredFields = {'world', 'environment'};
for i = 1:numel(requiredFields)
  if ~isfield(config, requiredFields{i})
    error('generateTrees:MissingField', ...
      'config.%s is required.', requiredFields{i});
  end
end

envFields = {'numTrees', 'treeHeightRange', 'crownRadiusRange', 'treeMargin'};
for i = 1:numel(envFields)
  if ~isfield(config.environment, envFields{i})
    error('generateTrees:MissingField', ...
      'config.environment.%s is required.', envFields{i});
  end
end

if ~isfield(config.world, 'size')
  error('generateTrees:MissingField', 'config.world.size is required.');
end

worldSize = config.world.size;
numTrees = config.environment.numTrees;
heightRange = config.environment.treeHeightRange;
crownRadiusRange = config.environment.crownRadiusRange;
treeMargin = config.environment.treeMargin;

xMin = treeMargin;
xMax = worldSize(1) - treeMargin;
yMin = treeMargin;
yMax = worldSize(2) - treeMargin;

if numTrees == 0
  trees = struct('ID', {}, 'Position', {}, 'BasePosition', {}, ...
    'TopPosition', {}, 'Height', {}, 'CrownRadius', {});
  return;
end

trees(numTrees) = struct('ID', [], 'Position', [], 'BasePosition', [], ...
  'TopPosition', [], 'Height', [], 'CrownRadius', []);

for i = 1:numTrees
  x = xMin + (xMax - xMin) * rand();
  y = yMin + (yMax - yMin) * rand();
  height = heightRange(1) + (heightRange(2) - heightRange(1)) * rand();
  crownRadius = crownRadiusRange(1) + ...
    (crownRadiusRange(2) - crownRadiusRange(1)) * rand();

  basePosition = [x; y; 0];
  topPosition = [x; y; height];

  trees(i).ID = i;
  trees(i).Position = basePosition;
  trees(i).BasePosition = basePosition;
  trees(i).TopPosition = topPosition;
  trees(i).Height = height;
  trees(i).CrownRadius = crownRadius;
end
end
