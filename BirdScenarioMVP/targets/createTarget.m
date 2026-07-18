function target = createTarget(id, className, subtype, config, context)
% createTarget - Создаёт одну цель (для сценариев предпочтительнее createTargets).
arguments
    id (1, 1) {mustBePositive, mustBeInteger}
    className (1, 1) string
    subtype (1, 1) string
    config (1, 1) struct
    context (1, 1) struct
end

if className == "bird" && subtype == "bird"
    if ~isfield(context, 'Trees')
        error('createTarget:MissingContext', 'context.Trees is required.');
    end
    target = createBirdTarget(id, config, context.Trees);
elseif className == "air" && subtype == "quadcopter"
    target = createQuadcopterTarget(id, config);
elseif className == "air" && subtype == "fixedWingUAV"
    if isfield(config, 'fixedWing2') && isfield(config.fixedWing2, 'enabled') && ...
            config.fixedWing2.enabled
        target = fw2_createFixedWingTarget(id, config);
    else
        target = createFixedWingTarget(id, config);
    end
elseif className == "ground" && subtype == "vehicle"
    if ~isfield(context, 'RoadNetwork')
        error('createTarget:MissingContext', 'context.RoadNetwork is required.');
    end
    target = createGroundVehicleTarget(id, config, context.RoadNetwork);
else
    error('createTarget:UnsupportedClass', ...
        'Unsupported target class: %s / %s.', className, subtype);
end
end
