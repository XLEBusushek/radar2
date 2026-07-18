function rcs = assignRCS(className, config)
% assignRCS - Назначение случайного значения RCS для класса цели.
arguments
    className (1, 1) string
    config (1, 1) struct
end

if className == "bird"
    if ~isfield(config, 'birds') || ~isfield(config.birds, 'rcsRange')
        error('assignRCS:MissingField', 'config.birds.rcsRange is required.');
    end
    range = config.birds.rcsRange;
elseif className == "quadcopter" || (className == "air")
    if ~isfield(config, 'quadcopter') || ~isfield(config.quadcopter, 'rcsRange')
        error('assignRCS:MissingField', 'config.quadcopter.rcsRange is required.');
    end
    range = config.quadcopter.rcsRange;
elseif className == "ground" || className == "vehicle"
    if ~isfield(config, 'groundVehicle') || ~isfield(config.groundVehicle, 'rcsRange')
        error('assignRCS:MissingField', 'config.groundVehicle.rcsRange is required.');
    end
    range = config.groundVehicle.rcsRange;
elseif className == "fixedWingUAV" || className == "fixedWing"
    if ~isfield(config, 'fixedWing') || ~isfield(config.fixedWing, 'rcsRange')
        error('assignRCS:MissingField', 'config.fixedWing.rcsRange is required.');
    end
    range = config.fixedWing.rcsRange;
else
    error('assignRCS:UnsupportedClass', ...
        'Unsupported target class: %s.', className);
end
rcs = range(1) + rand() * (range(2) - range(1));
end
