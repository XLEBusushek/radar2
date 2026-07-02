function target = createTarget(id, className, subtype, config, context)
% createTarget - Create a target of the given class (bird only at this stage).
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
    target = createFixedWingTarget(id, config);
else
    error('createTarget:UnsupportedClass', ...
        'Unsupported target class: %s / %s.', className, subtype);
end
end
