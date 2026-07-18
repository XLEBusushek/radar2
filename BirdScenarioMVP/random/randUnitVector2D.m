function v = randUnitVector2D()
% randUnitVector2D - Возврат случайного единичного вектора в плоскости XY.
theta = 2 * pi * rand();
v = [cos(theta); sin(theta); 0];
end
