function target = initializeFixedWingActiveLeg(target, config)
% initializeFixedWingActiveLeg - Set active route leg from current waypoint index.
arguments
    target (1, 1) struct
    config (1, 1) struct %#ok<INUSD>
end

idx = target.Payload.CurrentWaypointIndex;
waypoints = target.Payload.Waypoints;
legEnd = target.Payload.CurrentWaypoint(:);

if idx > 1 && idx <= size(waypoints, 1)
    legStart = waypoints(idx - 1, :).';
else
    legStart = target.Position(:);
end

legStart(3) = legEnd(3);
legVec = legEnd(1:2) - legStart(1:2);
legLength = norm(legVec);
if legLength < 1e-6
    heading = target.Payload.CurrentHeading;
    if isnan(heading)
        heading = atan2(target.Velocity(2), target.Velocity(1));
    end
    legDirection = [cos(heading); sin(heading)];
    legLength = max(legLength, 1);
else
    legDirection = legVec / legLength;
end

target.Payload.ActiveLegStart = legStart;
target.Payload.ActiveLegEnd = legEnd;
target.Payload.ActiveLegIndex = idx;
target.Payload.ActiveLegLength = legLength;
target.Payload.ActiveLegDirection = legDirection;
target.Payload.PreviousLegDirection = legDirection;

if isfield(target.Payload, 'PreviousLegDirection') && ~isempty(target.Payload.PreviousLegDirection) && ...
        idx > 1
    prevDir = target.Payload.PreviousLegDirection(:);
    if norm(prevDir) > 1e-6
        target.Payload.PreviousLegDirection = prevDir / norm(prevDir);
    end
end

if idx < size(waypoints, 1)
    nextVec = waypoints(idx + 1, 1:2).' - legEnd(1:2);
    if norm(nextVec) > 1e-6
        target.Payload.NextLegDirection = nextVec / norm(nextVec);
    else
        target.Payload.NextLegDirection = legDirection;
    end
else
    target.Payload.NextLegDirection = legDirection;
end

pos = target.Position(:);
sAlong = dot(pos(1:2) - legStart(1:2), legDirection);
target.Payload.ActiveLegProgress = sAlong / max(legLength, 1);
end
