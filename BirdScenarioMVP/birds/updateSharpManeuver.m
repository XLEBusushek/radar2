function bird = updateSharpManeuver(bird, config)
% updateSharpManeuver - Deactivate sharp maneuver after its duration expires.
arguments
    bird (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
end

if ~bird.Payload.IsSharpManeuverActive
    return;
end

if isempty(bird.Payload.SharpManeuverEndTime)
    bird.Payload.IsSharpManeuverActive = false;
    return;
end

if bird.CurrentTime >= bird.Payload.SharpManeuverEndTime
    bird.Payload.IsSharpManeuverActive = false;
    bird.Payload.SharpManeuverEndTime = [];
    bird.Payload.SharpManeuverDirection = [0; 0; 0];
end
end
