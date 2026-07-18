function birds = createBirds(config, trees)
% createBirds - Фабрика совместимости (используйте createTargets).
% Устаревший помощник для ручного использования/тестов; не используется в runSimulation.
arguments
    config (1, 1) struct
    trees struct
end

if ~isfield(config, 'birds') || ~isfield(config.birds, 'count')
    error('createBirds:MissingField', 'config.birds.count is required.');
end

numBirds = config.birds.count;

if numBirds == 0
    birds = struct('ID', {}, 'Class', {}, 'Subtype', {}, ...
        'Position', {}, 'Velocity', {}, 'Acceleration', {}, ...
        'RCS', {}, 'Visible', {}, 'State', {}, 'Mission', {}, ...
        'TimeInState', {}, 'CurrentTime', {}, 'StateMatrix', {}, ...
        'History', {}, 'Payload', {}, 'Behavior', {}, 'Metadata', {});
    return;
end

for i = 1:numBirds
    birds(i) = createBird(i, config, trees);
end
end
