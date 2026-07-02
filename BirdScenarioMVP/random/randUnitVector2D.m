function v = randUnitVector2D()
% randUnitVector2D - Return random unit vector in XY plane.
theta = 2 * pi * rand();
v = [cos(theta); sin(theta); 0];
end
