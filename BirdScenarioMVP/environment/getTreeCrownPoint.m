function point = getTreeCrownPoint(tree)
% getTreeCrownPoint - Return a random point inside the tree crown.
arguments
    tree (1, 1) struct
end

crownCenter = tree.TopPosition - [0; 0; tree.CrownRadius * 0.5];

% Uniform random point inside a sphere of radius CrownRadius.
direction = randn(3, 1);
direction = direction / norm(direction);
radius = tree.CrownRadius * rand()^(1 / 3);
offset = radius * direction;

point = crownCenter + offset;
point(3) = max(point(3), 0);
point = point(:);
end
