function plotWorldBox(worldSize)
% plotWorldBox - Draw the world bounding box edges.
arguments
    worldSize (1, 3) double
end

xMax = worldSize(1);
yMax = worldSize(2);
zMax = worldSize(3);

corners = [
    0,   0,   0;
    xMax, 0,   0;
    xMax, yMax, 0;
    0,   yMax, 0;
    0,   0,   zMax;
    xMax, 0,   zMax;
    xMax, yMax, zMax;
    0,   yMax, zMax];

edges = [
    1, 2; 2, 3; 3, 4; 4, 1;
    5, 6; 6, 7; 7, 8; 8, 5;
    1, 5; 2, 6; 3, 7; 4, 8];

hold on;
for i = 1:size(edges, 1)
    idx = edges(i, :);
    plot3(corners(idx, 1), corners(idx, 2), corners(idx, 3), ...
        'Color', [0.4, 0.4, 0.4], 'LineWidth', 0.8, ...
        'HandleVisibility', 'off');
end
plot3(nan, nan, nan, 'Color', [0.4, 0.4, 0.4], 'LineWidth', 0.8, ...
    'DisplayName', 'World bounds');
end
