function quad = resetQuadcopterNavigationFlags(quad)
% resetQuadcopterNavigationFlags - Сбросить состояние восстановления при отсутствии прогресса.
arguments
    quad (1, 1) struct
end

quad.Payload.NoProgressTime = 0;
quad.Payload.PreviousDistanceToWaypoint = [];
quad.Payload.ForceDirectToWaypoint = false;
end
