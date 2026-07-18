function target = updateQuadcopterMotionCommand(target, config)
% updateQuadcopterMotionCommand - Вычислить желаемую скорость для текущего состояния.
target = computeQuadcopterDesiredVelocity(target, config);
end
