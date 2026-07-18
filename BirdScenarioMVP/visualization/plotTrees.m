function plotTrees(trees, config)
% plotTrees - Рисование деревьев на текущих осях (ствол + опциональная крона).
arguments
    trees struct
    config (1, 1) struct = defaultPlotTreesConfig()
end

if isempty(trees)
    return;
end

showCrowns = true;
maxTrees = numel(trees);
if nargin >= 2 && isfield(config, 'visualization')
    if isfield(config.visualization, 'showTreeCrowns')
        showCrowns = config.visualization.showTreeCrowns;
    end
    if isfield(config.visualization, 'maxTreesToDraw')
        maxTrees = config.visualization.maxTreesToDraw;
    end
end

treeIndices = 1:numel(trees);
if numel(trees) > maxTrees
    step = ceil(numel(trees) / maxTrees);
    treeIndices = 1:step:numel(trees);
end

hold on;

for k = 1:numel(treeIndices)
    i = treeIndices(k);
    tree = trees(i);
    x = tree.Position(1);
    y = tree.Position(2);
    height = tree.Height;
    r = tree.CrownRadius;
    crownCenterZ = height - r * 0.5;

    plot3([x, x], [y, y], [0, height], 'Color', [0.35, 0.2, 0.05], ...
        'LineWidth', 0.6, 'HandleVisibility', 'off');

    if showCrowns
        [Xs, Ys, Zs] = sphere(6);
        surf(x + r * Xs, y + r * Ys, crownCenterZ + r * Zs, ...
            'FaceColor', [0.2, 0.6, 0.2], 'EdgeColor', 'none', ...
            'FaceAlpha', 0.25, 'HandleVisibility', 'off');
    end
end

plot3(nan, nan, nan, 'Color', [0.35, 0.2, 0.05], 'LineWidth', 0.6, ...
    'DisplayName', 'Trees');
end

function config = defaultPlotTreesConfig()
config.visualization.showTreeCrowns = true;
config.visualization.maxTreesToDraw = 80;
end
