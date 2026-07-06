function quad = resetQuadcopterNavigationFlags(quad)
% resetQuadcopterNavigationFlags - Clear no-progress recovery state.
arguments
    quad (1, 1) struct
end

quad.Payload.NoProgressTime = 0;
quad.Payload.PreviousDistanceToWaypoint = [];
quad.Payload.ForceDirectToWaypoint = false;
end
