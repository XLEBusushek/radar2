function forceTransit = shouldForceQuadcopterTransit(quad, config)
% shouldForceQuadcopterTransit - Решить, должен ли hover/scan уступить transit.
arguments
    quad (1, 1) struct
    config (1, 1) struct
end

forceTransit = false;
if ~isfield(config.quadcopter, 'navigation') || ~config.quadcopter.navigation.enabled
    return;
end

nav = config.quadcopter.navigation;
state = string(quad.State);

if state == "Hover"
    if quad.Payload.ConsecutiveHoverCount >= nav.maxConsecutiveHover
        forceTransit = true;
        return;
    end
    if nav.forceTransitAfterAction && ~isempty(quad.Payload.HoverDuration) && ...
            quad.TimeInState >= quad.Payload.HoverDuration
        forceTransit = true;
    end
elseif state == "Scan"
    if quad.Payload.ConsecutiveScanCount >= nav.maxConsecutiveScan
        forceTransit = true;
        return;
    end
    if nav.forceTransitAfterAction && ~isempty(quad.Payload.ScanStartTime) && ...
            ~isempty(quad.Payload.ScanDuration) && ...
            quad.CurrentTime >= quad.Payload.ScanStartTime + quad.Payload.ScanDuration
        forceTransit = true;
    end
end
end
