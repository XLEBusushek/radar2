function sideDir = computePerpendicular2D(direction)
% computePerpendicular2D - Return a horizontal unit vector perpendicular to direction.
direction = direction(:);
horizontalNorm = norm(direction(1:2));

if horizontalNorm < 1e-9
    sideDir = [1; 0; 0];
    return;
end

sideDir = [-direction(2); direction(1); 0];
sideDir = sideDir / norm(sideDir);
end
