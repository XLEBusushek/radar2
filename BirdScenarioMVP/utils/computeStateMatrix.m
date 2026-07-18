function stateMatrix = computeStateMatrix(position, velocity)
% computeStateMatrix - Построение матрицы состояния 3x2 из позиции и скорости.
position = position(:);
velocity = velocity(:);

stateMatrix = [position(1), velocity(1);
               position(2), velocity(2);
               position(3), velocity(3)];
end
