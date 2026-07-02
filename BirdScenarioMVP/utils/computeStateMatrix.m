function stateMatrix = computeStateMatrix(position, velocity)
% computeStateMatrix - Build 3x2 state matrix from position and velocity.
position = position(:);
velocity = velocity(:);

stateMatrix = [position(1), velocity(1);
               position(2), velocity(2);
               position(3), velocity(3)];
end
