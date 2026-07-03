function target = updateFixedWingActiveLeg(target, config, dt)
% updateFixedWingActiveLeg - Update leg progress and leg transition state.
arguments
    target (1, 1) struct
    config (1, 1) struct
    dt (1, 1) double {mustBePositive}
end

if ~isfield(target.Payload, 'ActiveLegStart') || isempty(target.Payload.ActiveLegStart)
    target = initializeFixedWingActiveLeg(target, config);
end

legStart = target.Payload.ActiveLegStart(:);
legDirection = target.Payload.ActiveLegDirection(:);
legLength = target.Payload.ActiveLegLength;
pos = target.Position(:);

sAlong = dot(pos(1:2) - legStart(1:2), legDirection);
target.Payload.ActiveLegProgress = sAlong / max(legLength, 1);

if isfield(target.Payload, 'LegTransitionActive') && target.Payload.LegTransitionActive
    transitionDuration = getFixedWingNavConfigValue(config, 'legTransitionDuration', '', 8);
    elapsed = target.CurrentTime - target.Payload.LegTransitionStartTime;
    if elapsed >= transitionDuration || target.Payload.ActiveLegProgress >= 0.2
        target.Payload.LegTransitionActive = false;
    end
end
end
