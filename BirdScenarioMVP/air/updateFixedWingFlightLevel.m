function target = updateFixedWingFlightLevel(target, config)
% updateFixedWingFlightLevel - Rarely move fixed-wing UAV to a neighboring flight level.
arguments
    target (1, 1) struct
    config (1, 1) struct
end

fl = config.fixedWing.flightLevel;
if ~fl.enabled || rand() > fl.changeProbability
    return;
end

levels = fl.levelRange(1):fl.levelSpacing:fl.levelRange(2);
if isempty(levels)
    return;
end

idx = target.Payload.FlightLevelIndex;
if isempty(idx) || idx < 1 || idx > numel(levels)
    [~, idx] = min(abs(levels - target.Payload.TargetFlightLevel));
end

maxStep = max(1, fl.maxLevelChange);
delta = randi([-maxStep, maxStep]);
if delta == 0 && numel(levels) > 1
    delta = 1;
end
newIdx = min(max(idx + delta, 1), numel(levels));
level = levels(newIdx);

target.Payload.FlightLevelIndex = newIdx;
target.Payload.TargetFlightLevel = level;
target.Payload.FlightLevel = level;
target.Payload.AltitudeBand = [level - fl.altitudeTolerance, level + fl.altitudeTolerance];
target.Payload.LastNavigationEvent = "flightLevelChange";
end
