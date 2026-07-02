function quad = updateQuadcopterExcursionMetrics(quad)
% updateQuadcopterExcursionMetrics - Accumulate horizontal travel and altitude extrema.
arguments
    quad (1, 1) struct
end

if ~isfield(quad.Payload, 'LastPositionForExcursion') || ...
        isempty(quad.Payload.LastPositionForExcursion)
    quad.Payload.LastPositionForExcursion = quad.Position;
end

previousPosition = quad.Payload.LastPositionForExcursion(:);
currentPosition = quad.Position(:);
deltaXY = currentPosition(1:2) - previousPosition(1:2);

quad.Payload.TotalXYExcursion = quad.Payload.TotalXYExcursion + norm(deltaXY);
quad.Payload.MaxAltitudeReached = max(quad.Payload.MaxAltitudeReached, currentPosition(3));
quad.Payload.MinAltitudeReached = min(quad.Payload.MinAltitudeReached, currentPosition(3));
quad.Payload.LastPositionForExcursion = currentPosition;
end
