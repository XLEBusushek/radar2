function target = updateQuadcopterMotionCommand(target, config)
% updateQuadcopterMotionCommand - Compute desired velocity for current state.
target = computeQuadcopterDesiredVelocity(target, config);
end
