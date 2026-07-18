function plotRoadNetwork(roadNetwork, varargin)
% plotRoadNetwork - Отображение полилиний дорог на текущих осях.
arguments
    roadNetwork (1, 1) struct
end
arguments (Repeating)
    varargin
end

if ~isfield(roadNetwork, 'Edges') || isempty(roadNetwork.Edges)
    return;
end

ax = gca;
if ~isempty(varargin) && isgraphics(varargin{1}, 'axes')
    ax = varargin{1};
end

hold(ax, 'on');
for i = 1:numel(roadNetwork.Edges)
    edge = roadNetwork.Edges(i);
    points = edge.Points;
    if size(points, 1) < 2
        continue;
    end
    [color, lineWidth] = roadStyle(edge);
    plot3(ax, points(:, 1), points(:, 2), points(:, 3), '-', ...
        'Color', color, 'LineWidth', lineWidth, 'HandleVisibility', 'off');
end

if isfield(roadNetwork, 'Nodes') && ~isempty(roadNetwork.Nodes)
    nodeTypes = string({roadNetwork.Nodes.Type});
    intersections = roadNetwork.Nodes(nodeTypes == "intersection");
    if ~isempty(intersections)
        pos = reshape([intersections.Position], 3, []).';
    else
        pos = zeros(0, 3);
    end
elseif isfield(roadNetwork, 'Intersections') && ~isempty(roadNetwork.Intersections)
    pos = reshape([roadNetwork.Intersections.Position], 3, []).';
else
    pos = zeros(0, 3);
end
if ~isempty(pos)
    scatter3(ax, pos(:, 1), pos(:, 2), pos(:, 3), 20, [0.05, 0.05, 0.05], ...
        'filled', 'HandleVisibility', 'off');
end

plot3(ax, nan, nan, nan, '-', 'Color', [0.05, 0.05, 0.05], ...
    'LineWidth', 3, 'DisplayName', 'Main roads');
plot3(ax, nan, nan, nan, '-', 'Color', [0.35, 0.35, 0.35], ...
    'LineWidth', 1.8, 'DisplayName', 'Secondary roads');
plot3(ax, nan, nan, nan, '.', 'Color', [0.05, 0.05, 0.05], ...
    'MarkerSize', 14, 'DisplayName', 'Intersections');
end

function [color, lineWidth] = roadStyle(edge)
switch string(edge.Type)
    case "main"
        color = [0.05, 0.05, 0.05];
        lineWidth = 3.0;
    case "dirt"
        color = [0.45, 0.35, 0.25];
        lineWidth = 1.4;
    otherwise
        color = [0.35, 0.35, 0.35];
        lineWidth = 1.8;
end
end
